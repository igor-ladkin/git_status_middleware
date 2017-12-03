require "git_status"

describe GitStatus do
  let(:git_status) { described_class.new }

  describe "#to_h" do
    subject { git_status.to_h }

    it "includes error message if git is not configured" do
      allow(git_status).to receive(:git_installed?).and_return(false)
      allow(git_status).to receive(:git_initialized?).and_return(false)

      expect(subject[:error_message]).to be_truthy
    end

    it "includes installation instruction when git is not installed" do
      allow(git_status).to receive(:git_installed?).and_return(false)
      expect(subject[:error_message]).to include("Git is not installed. Install!")
    end

    it "includes initialization instruction when git is not initialized" do
      allow(git_status).to receive(:git_initialized?).and_return(false)
      expect(subject[:error_message]).to include("Git is not initialized. Initialize!")
    end

    context "when git is not set up" do
      it "returns nil for branch, revision and changes", :aggregate_failures do
        allow(git_status).to receive(:git_configured?).and_return(false)

        expect(subject[:branch]).to be_nil
        expect(subject[:revision]).to be_nil
        expect(subject[:changes]).to be_nil
      end
    end

    context "when git is properly set up" do
      before do
        allow(git_status).to receive(:git_configured?).and_return(true)
      end

      it "includes branch name" do
        expect(subject[:branch]).to be_truthy
      end

      it "includes revision" do
        expect(subject[:revision]).to be_truthy
      end

      it "includes formatted string for changes for first example", :aggregate_failures do
        status_string =
          <<~EOF
           D config.ru
          A  dummy.txt
          M  lib/git_status_middleware.rb
           M spec/git_status_middleware_spec.rb
          ?? lib/git_status.rb
          ?? spec/git_status_spec.rb
          EOF

        allow(git_status).to receive(:status_string).and_return(status_string)

        expect(subject[:changes]).to match(/C: (\d+), U: (\d+), S: (\d+)/)
        expect(subject[:changes]).to eq("C: 4, U: 2, S: 2")
      end

      it "includes formatted string for changes for second example", :aggregate_failures do
        status_string =
          <<~EOF
           D config.ru
          M  lib/git_status_middleware.rb
           M spec/git_status_middleware_spec.rb
          EOF

        allow(git_status).to receive(:status_string).and_return(status_string)

        expect(subject[:changes]).to match(/C: (\d+), U: (\d+), S: (\d+)/)
        expect(subject[:changes]).to eq("C: 3, U: 0, S: 1")
      end

      it "includes 'Nothing yet' as changes for empty changes" do
        allow(git_status).to receive(:status_string).and_return("")
        expect(subject[:changes]).to eq("Nothing yet")
      end
    end
  end
end
