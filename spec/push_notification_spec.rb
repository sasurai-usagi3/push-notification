require "spec_helper"

RSpec.describe PushNotification do
  it "has a version number" do
    expect(PushNotification::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
