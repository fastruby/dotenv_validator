require "spec_helper"

RSpec.describe DotenvChecker do
  let(:sample_lines) { StringIO.new("") }

  before do
    allow(File).to receive(:exist?).and_return(true)
    allow(DotenvChecker).to receive(:open_sample_file).and_return(sample_lines)
  end

  describe ".check" do
    context "when there are no variables" do
      it "returns true" do
        expect(DotenvChecker.check).to be_truthy
      end
    end

    context "when there is a variable that is required" do
      let(:sample_lines) do
        StringIO.new("admin_password=super_secret # required")
      end

      context "and ENV has said variable" do
        it "returns true" do
          ClimateControl.modify admin_password: "solarwinds123" do
            expect(DotenvChecker.check).to be_truthy
          end
        end
      end

      context "and ENV does not have said variable" do
        it "returns false" do
          expect(DotenvChecker.check).to be_falsey
        end
      end
    end
  end
end