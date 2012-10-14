require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Tekeya" do
  describe "Feed" do
    before :each do
      @user = Fabricate(:user)
      @user2 = Fabricate(:user)
      @user3 = Fabricate(:user)

      @user2.track(@user)
      @user3.track(@user)

      @act1 = @user.activities.create activity_type: "like", attachments: [Fabricate.build(:attachment), Fabricate.build(:attachment)]
      @act2 = @user.activities.create activity_type: "like", attachments: [Fabricate.build(:attachment)]
      @act3 = @user.activities.create activity_type: "share", attachments: [Fabricate.build(:attachment)]

      @act4 = @user.activities.new activity_type: "like", attachments: [Fabricate.build(:attachment)]
      @act4.stub(:current_time_from_proper_timezone => @act1.created_at + 20.minutes)
      @act4.save!
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
    end

    it "should add the activity to the owner's profile feed and group activities of the same type within 15 min" do
      @user.profile_feed[0].activity_type.should == @act1.activity_type
      @user.profile_feed[1].activity_type.should == @act3.activity_type
      @user.profile_feed[2].activity_type.should == @act4.activity_type
      @user.profile_feed.count.should == 3
    end

    it "should not save the activity in the DB if its grouped with another" do
      @act2.persisted?.should_not == true
    end

    it "should save the activity's attachments in the parent activity if its grouped" do
      @act1.reload
      (@act1.attachments & @act2.attachments).should == @act2.attachments
    end

    it "should fanout activities to the entity's trackers" do
      @user2.feed[0].activity_type.should == @act1.activity_type
      @user2.feed[1].activity_type.should == @act3.activity_type
      @user2.feed[2].activity_type.should == @act4.activity_type

      @user3.feed[0].activity_type.should == @act1.activity_type
      @user3.feed[1].activity_type.should == @act3.activity_type
      @user3.feed[2].activity_type.should == @act4.activity_type
    end

    describe "invalid profile feed cache" do
      before :all do
        ::Tekeya::Activity.any_instance.stub(:write_activity_in_redis => true)
      end

      it "should return profile activities from the DB when the profile cache is empty" do
        @act1.cached_in_redis?.should == false
        @act3.cached_in_redis?.should == false
        @act4.cached_in_redis?.should == false
        @user.profile_feed.count.should == 3
      end
    end

    describe "invalid feed cache" do
      it "should return feed activities from the DB when the feed cache is empty" do
        ::Tekeya.redis.del(@user2.feed_key)
        ::Tekeya.redis.del(@user3.feed_key)

        ::Tekeya.redis.zcard(@user2.feed_key).should == 0
        ::Tekeya.redis.zcard(@user3.feed_key).should == 0
        @user2.feed.count == 3
        @user3.feed.count == 3
      end
    end

    describe "activity deletion" do
      before :each do
        @act1.destroy
        @act3.destroy
        @act4.destroy
      end

      it "should remove the activity from the cache when its deleted from the db" do
        @act1.cached_in_redis?.should_not == true
        @act3.cached_in_redis?.should_not == true
        @act4.cached_in_redis?.should_not == true
      end

      it "should remove the activity from the profile cache when its deleted from the db" do 
        @user.profile_feed.count.should == 0
      end

      it "should remove the activity from the trackers' feed when its deleted from the db" do
        @user2.feed.count.should == 0
        @user3.feed.count.should == 0
      end
    end

    describe "untracking" do
      before :each do
        @user2.untrack(@user)
      end

      it "should remove the feed of the untracked entity from the tracker's cache" do
        @user2.feed.count.should == 0
        @user3.feed.count.should == 3 # just to make sure that only user2 is affected
      end
    end

    describe "tracking" do
      before :each do
        @user4 = Fabricate(:user)

        @user4.track(@user)
      end

      it "should copy the feed of the tracked entity into the tracker's feed" do
        @user4.feed.count.should == 3
      end
    end
  end
end