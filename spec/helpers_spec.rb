require 'spec_helper'

describe Mconnect::Helpers do
  include Mconnect::Helpers

  describe "#load_yaml" do
    let(:data) { { token: "XXXXXX", secret: "YYYYYY" } }

    it "takes a hash as a parameter" do
      expect(load_yaml(data)).to be_kind_of Hash
    end

    it "takes a file as a parameter" do
      allow(YAML).to receive(:load_file).with('config.yml').and_return(data)
      expect(load_yaml("config.yml")).to be_kind_of Hash
    end
  end
end
