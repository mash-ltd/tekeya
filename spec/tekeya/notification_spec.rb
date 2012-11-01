require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Tekeya" do
  describe "Notification" do
    before :each do
      @user = Fabricate(:user)
      @user1 = Fabricate(:user)
    end

    describe "DSL" do
      before :each do
        @user1.track @user
        @user.notifications.poked_by @user1

        @user2 = Fabricate(:user)
        @user3 = Fabricate(:user)
        @user4 = Fabricate(:user)

        @status = Fabricate(:status)
      end

      it "should create a notification in redis" do
        @user.notifications.empty?.should == false
        @user.notifications.first.cached_in_redis?.should == true
      end

      it "should notify the entity with the proper notification data" do
        tracked_notification = @user.notifications.first

        tracked_notification.notification_type.should == "tracked_by"
        tracked_notification.subject.should == @user
        tracked_notification.actors.map(&:attachable_id).include?(@user1.id).should == true

        poked_notification = @user.notifications.last

        poked_notification.notification_type.should == "poked_by"
        poked_notification.subject.should == @user
        poked_notification.actors.map(&:attachable_id).include?(@user1.id).should == true
      end

      it "should notify multiple entities" do
        Tekeya::Notification.notify! [@user2, @user3, @user4], :posted, @status, @user

        ((@user2.notifications == @user3.notifications) == (@user4.notifications == 1)).should == true
      end
    end

  end
end