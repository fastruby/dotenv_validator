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

        it "displays a warning message in STDOUT" do
          msg = "WARNING - Missing environment variables: admin_password\n"
          expect do
            DotenvChecker.check
          end.to output(msg).to_stdout
        end
      end
    end

    context "when there is a variable that is optional" do
      context "and ENV does not have said variable" do
        let(:sample_lines) { StringIO.new("DISCOUNT=20") }

        it "returns true" do
          expect(DotenvChecker.check).to be_truthy
        end
      end

      context "and there is an integer format parameter in the comment" do
        let(:sample_lines) { StringIO.new("DISCOUNT=20 # format=integer") }

        context "and ENV variable is an integer" do
          it "returns true" do
            ClimateControl.modify DISCOUNT: "42" do
              expect(DotenvChecker.check).to be_truthy
            end
          end
        end

        context "and ENV variable is not an integer" do
          it "returns false" do
            ClimateControl.modify DISCOUNT: "twenty" do
              expect(DotenvChecker.check).to be_falsey
            end
          end

          it "displays a warning message in STDOUT" do
            msg = "WARNING - Environment variables with invalid format: DISCOUNT\n"

            ClimateControl.modify DISCOUNT: "twenty" do
              expect do
                DotenvChecker.check
              end.to output(msg).to_stdout
            end
          end
        end
      end

      context "and there is an url format parameter in the comment" do
        let(:sample_lines) { StringIO.new("DISCOUNT_URL=http://google.com # format=url") }

        context "and ENV variable is an url" do
          it "returns true" do
            ClimateControl.modify DISCOUNT_URL: "https://fastruby.io" do
              expect(DotenvChecker.check).to be_truthy
            end
          end
        end

        context "and ENV variable is not an url" do
          it "returns false" do
            ClimateControl.modify DISCOUNT_URL: "foo/bar" do
              expect(DotenvChecker.check).to be_falsey
            end
          end

          it "displays a warning message in STDOUT" do
            msg = "WARNING - Environment variables with invalid format: DISCOUNT_URL\n"

            ClimateControl.modify DISCOUNT_URL: "foo/bar" do
              expect do
                DotenvChecker.check
              end.to output(msg).to_stdout
            end
          end
        end
      end

      context "and there is a regexp format parameter in the comment" do
        let(:sample_lines) { StringIO.new('KEY_ID=123_ABC # format=\d{3}_\w{3}') }

        context "and ENV variable matches regexp" do
          it "returns true" do
            ClimateControl.modify KEY_ID: "567_FOO" do
              expect(DotenvChecker.check).to be_truthy
            end
          end
        end

        context "and ENV variable is not an url" do
          it "returns false" do
            ClimateControl.modify KEY_ID: "567_12" do
              expect(DotenvChecker.check).to be_falsey
            end
          end

          it "displays a warning message in STDOUT" do
            msg = "WARNING - Environment variables with invalid format: KEY_ID\n"

            ClimateControl.modify KEY_ID: "567_88" do
              expect do
                DotenvChecker.check
              end.to output(msg).to_stdout
            end
          end
        end
      end
    end
  end
end