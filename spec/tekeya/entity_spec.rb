require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Tekeya" do
  describe "Entity" do
    before :each do
      @user = Fabricate(:user)
      @user2 = Fabricate(:user)
      @group = Fabricate(:group)
    end

    it "should inherit all the relations and feed methods" do
      # Public methods
      User.method_defined?(:track).should == true
      User.method_defined?(:tracking).should == true
      User.method_defined?(:"tracks?").should == true
      User.method_defined?(:untrack).should == true
      User.method_defined?(:block).should == true
      User.method_defined?(:blocked).should == true
      User.method_defined?(:"blocks?").should == true
      User.method_defined?(:unblock).should == true
      User.method_defined?(:join).should == true
      User.method_defined?(:groups).should == true
      User.method_defined?(:"member_of?").should == true
      User.method_defined?(:leave).should == true
      User.method_defined?(:profile_feed).should == true
      User.method_defined?(:feed).should == true
      User.method_defined?(:profile_feed_key).should == true
      User.method_defined?(:feed_key).should == true
      # Private methods
      User.private_method_defined?(:add_relation).should == true
      User.private_method_defined?(:delete_relation).should == true
      User.private_method_defined?(:relations_of).should == true
      User.private_method_defined?(:"relation_exists?").should == true
    end

    describe "errors" do
      it "should raise a non entity error when tracking or blocking a non entity" do
        expect { @user.track(nil) }.to raise_error(Tekeya::Errors::TekeyaNonEntity)
        expect { @user.block(nil) }.to raise_error(Tekeya::Errors::TekeyaNonEntity)
      end

      it "should raise a non group error if a non group is given when joining a non group" do
        expect { @user.join(nil) }.to raise_error(Tekeya::Errors::TekeyaNonGroup)
      end

      it "should raise a relation already exists error when tracking, blocking or joining an already tracked, blocked or joined entity/group" do
        @user.track(@user2)
        expect { @user.track(@user2) }.to raise_error(Tekeya::Errors::TekeyaRelationAlreadyExists)
        @user.block(@user2)
        expect { @user.block(@user2) }.to raise_error(Tekeya::Errors::TekeyaRelationAlreadyExists)
        @user.join(@group)
        expect { @user.join(@group) }.to raise_error(Tekeya::Errors::TekeyaRelationAlreadyExists)
      end

      it "should raise a relation non existent error when untracking, unblocking or leaving an untracked, unblocked or unjoined entity/group" do
        expect { @user.untrack(@user2) }.to raise_error(Tekeya::Errors::TekeyaRelationNonExistent)
        expect { @user.unblock(@user2) }.to raise_error(Tekeya::Errors::TekeyaRelationNonExistent)
        expect { @user.leave(@group) }.to raise_error(Tekeya::Errors::TekeyaRelationNonExistent)
      end
    end

    describe "relations" do
      it "should track another entity" do
        @user.track(@user2).should == true
        @user.tracks?(@user2).should == true
      end

      it "should untrack a tracked entity" do
        @user.track(@user2)
        @user.untrack(@user2).should == true
        @user.tracks?(@user2).should_not == true
      end

      it "should block another entity/group" do
        @user.block(@user2).should == true
        @user.blocks?(@user2).should == true
        @user.block(@group).should == true
        @user.blocks?(@group).should == true
      end

      it "should unblock a blocked entity/group" do
        @user.block(@user2)
        @user.unblock(@user2).should == true
        @user.blocks?(@user2).should_not == true

        @user.block(@group)
        @user.unblock(@group).should == true
        @user.blocks?(@group).should_not == true
      end

      it "should join a group" do
        @user.join(@group).should == true
        @user.member_of?(@group).should == true
      end

      it "should leave a group" do
        @user.join(@group)
        @user.leave(@group).should == true
        @user.member_of?(@group).should_not == true
      end

      describe "retrieval" do
        before :each do
          @user3 = Fabricate(:user)
          @user.track(@user2)
          @user.block(@user3)
          @user.join(@group)
          @user2.join(@group)
          @user3.join(@group)
        end

        it "should return tracked entities" do
          @user.tracking.include?(@user2).should == true
        end

        it "should return trackers" do
          @user2.trackers.include?(@user).should == true
        end

        it "should return blocked entities" do
          @user.blocked.include?(@user3).should == true
        end

        it "should return joined groups" do
          @user.groups.include?(@group).should == true
        end

        it "should return group members" do
          @group.members.should == [@user, @user2, @user3]
        end
      end

      describe "blocking entities" do
        it "should remove the tracking relation if it exists" do
          @user.track(@user2)
          @user2.track(@user)
          @user.block(@user2)

          @user.tracks?(@user2).should_not == true
          @user2.tracks?(@user).should_not == true
        end
      end
    end
  end
end