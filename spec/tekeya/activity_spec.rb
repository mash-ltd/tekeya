require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Tekeya" do
  describe "Activity" do
    before :each do
      @user = Fabricate(:user)
      @user2 = Fabricate(:user)
      @user3 = Fabricate(:user)

      @user2.track(@user)
      @user3.track(@user)

      # Normal Activities (1 & 2 should be grouped)
      @act1 = @user.activities.liked Fabricate(:status), Fabricate(:status)
      @act2 = @user.activities.liked Fabricate(:status)
      @act3 = @user.activities.shared Fabricate(:status)

      # Created after the grouping interval
      @act4 = @user.activities.new activity_type: :liked, attachments: [Fabricate.build(:attachment)]
      @act4.stub(:current_time_from_proper_timezone => @act1.created_at + 20.minutes)
      @act4.save!

      # Manually not grouped
      @act5 = @user.activities.liked Fabricate(:status), group: false
    end

    it "should return the same aggregate key" do 
      @act1.activity_key.should == @act2.activity_key
    end

    it "should return different aggregate keys" do
      @act1.activity_key.should_not == @act3.activity_key
    end

    it "should create an aggregate in redis" do
      @act1.cached_in_redis?.should == true
      @act2.cached_in_redis?.should == true
      @act3.cached_in_redis?.should == true
      @act4.cached_in_redis?.should == true
      @act5.cached_in_redis?.should == true
    end

    it "should add the activity to the owner's profile feed and group activities of the same type within 15 min" do
      id_array = @user.profile_feed.map(&:activity_id)
      id_array.include?(@act1.id.to_s).should == true
      id_array.include?(@act3.id.to_s).should == true
      id_array.include?(@act4.id.to_s).should == true
      id_array.include?(@act5.id.to_s).should == true
    end

    it "should not save the activity in the DB if its grouped with another" do
      @act2.persisted?.should_not == true
    end

    it "should save the activity's attachments in the parent activity if its grouped" do
      @act1.reload
      (@act1.attachments & @act2.attachments).should == @act2.attachments
    end

    it "should fanout activities to the entity's trackers" do
      id_array = (@user2.feed.map(&:activity_id) + @user3.feed.map(&:activity_id)).uniq
      id_array.include?(@act1.id.to_s).should == true
      id_array.include?(@act3.id.to_s).should == true
      id_array.include?(@act4.id.to_s).should == true
      id_array.include?(@act5.id.to_s).should == true
    end

    describe "invalid profile feed cache" do
      it "should return profile activities from the DB when the profile cache is empty" do
        ::Tekeya.redis.del(@user.profile_feed_key)
        ::Tekeya.redis.del(@act1.activity_key)
        ::Tekeya.redis.del(@act3.activity_key)
        ::Tekeya.redis.del(@act4.activity_key)
        ::Tekeya.redis.del(@act5.activity_key)

        @act1.cached_in_redis?.should == false
        @act3.cached_in_redis?.should == false
        @act4.cached_in_redis?.should == false
        @act5.cached_in_redis?.should == false
        
        id_array = @user.profile_feed.map(&:activity_id)
        id_array.include?(@act1.id.to_s).should == true
        id_array.include?(@act3.id.to_s).should == true
        id_array.include?(@act4.id.to_s).should == true
        id_array.include?(@act5.id.to_s).should == true
      end
    end

    describe "invalid feed cache" do
      it "should return feed activities from the DB when the feed cache is empty" do
        ::Tekeya.redis.del(@user2.feed_key)
        ::Tekeya.redis.del(@user3.feed_key)

        ::Tekeya.redis.zcard(@user2.feed_key).should == 0
        ::Tekeya.redis.zcard(@user3.feed_key).should == 0

        @user2.feed.count == 4
        @user3.feed.count == 4
      end
    end

    describe "activity deletion" do
      before :each do
        @act1.destroy
        @act3.destroy
        @act4.destroy

        Timecop.travel(Time.at(20.minutes)) do
          @act5.destroy
        end
      end

      it "should remove the activity from the cache when its deleted from the db" do
        @act1.cached_in_redis?.should_not == true
        @act3.cached_in_redis?.should_not == true
        @act4.cached_in_redis?.should_not == true
        @act5.cached_in_redis?.should_not == true
      end

      it "should remove the activity from the profile cache when its deleted from the db" do 
        id_array = @user.profile_feed.map(&:activity_id)
        id_array.include?(@act1.id.to_s).should_not == true
        id_array.include?(@act3.id.to_s).should_not == true
        id_array.include?(@act4.id.to_s).should_not == true
        id_array.include?(@act5.id.to_s).should_not == true
      end

      it "should remove the activity from the trackers' feed when its deleted from the db" do
        id_array = (@user2.feed.map(&:activity_id) + @user3.feed.map(&:activity_id)).uniq
        id_array.include?(@act1.id.to_s).should_not == true
        id_array.include?(@act3.id.to_s).should_not == true
        id_array.include?(@act4.id.to_s).should_not == true
        id_array.include?(@act5.id.to_s).should_not == true
      end
    end

    describe "untracking" do
      before :each do
        @user2.untrack(@user)
      end

      it "should remove the feed of the untracked entity from the tracker's cache" do
        id_array = @user2.feed.map(&:activity_id)
        id_array.include?(@act1.id.to_s).should_not == true
        id_array.include?(@act3.id.to_s).should_not == true
        id_array.include?(@act4.id.to_s).should_not == true
        id_array.include?(@act5.id.to_s).should_not == true

        id_array = @user3.feed.map(&:activity_id)
        id_array.include?(@act1.id.to_s).should == true
        id_array.include?(@act3.id.to_s).should == true
        id_array.include?(@act4.id.to_s).should == true
        id_array.include?(@act5.id.to_s).should == true
      end
    end

    describe "tracking" do
      before :each do
        @user4 = Fabricate(:user)

        @user4.track(@user)
      end

      it "should copy the feed of the tracked entity into the tracker's feed" do
        id_array = @user4.feed.map(&:activity_id)
        id_array.include?(@act1.id.to_s).should == true
        id_array.include?(@act3.id.to_s).should == true
        id_array.include?(@act4.id.to_s).should == true
        id_array.include?(@act5.id.to_s).should == true
      end
    end
  end
end