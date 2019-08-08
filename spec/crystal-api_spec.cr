require "./spec_helper"

describe CrAPI do
  it "loads Crystal stdlib" do
    File.open("data/crystal_stdlib.json") do |file|
      CrAPI.from_json(file)
    end
  end
end
