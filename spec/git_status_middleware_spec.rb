require "git_status_middleware"

describe GitStatusMiddleware do
  let(:response_body) { "<html><body>Hello world!</body></html>" }
  let(:app) { double "Some Application", call: [200, {"Content-Type" => "text/html"}, [response_body]] }

  let(:middleware) { described_class.new(app) }
  let(:env) do
    {
      "SERVER_NAME" => "awesome.com",
      "SERVER_PORT" => 9000,
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/",
    }
  end

  describe "#call" do
    subject { middleware.call(env) }

    it "returns the same status code for SUCCESSFUL request" do
      allow(app).to receive(:call).with(env).and_return([200, {"Content-Type" => "text/html"}, [response_body]])

      status, _, _ = subject
      expect(status).to eq 200
    end

    it "returns the same status code for UNSUCCESSFUL request" do
      allow(app).to receive(:call).with(env).and_return([404, {"Content-Type" => "text/html"}, [response_body]])

      status, _, _ = subject
      expect(status).to eq 404
    end

    context "when git is not properly setup" do
      it "appends git setup instruction to response if git is not installed" do
        allow(middleware).to receive(:git_installed?).and_return(false)

        _, _, response = subject
        expect(response.join '').to include("Git is not installed. Install!")
      end

      it "appends git init instruction to response if git is not initialized" do
        allow(middleware).to receive(:git_initialized?).and_return(false)

        _, _, response = subject
        expect(response.join '').to include("Git is not initialized. Initialize!")
      end
    end

    context "when git is setup correctly" do
      before do
        allow(middleware).to receive(:git_installed?).and_return(true)
        allow(middleware).to receive(:git_initialized?).and_return(true)
      end

      it "shows current branch name in the response" do
        allow(middleware).to receive(:branch).and_return("master")

        _, _, response = subject
        expect(response.join "").to include("Branch: master")
      end

      it "shows current revision hash in the response" do
        allow(middleware).to receive(:revision).and_return("6ee72f00ddf66a0b5eca07452830fd4b7f5e7d21")

        _, _, response = subject
        expect(response.join "").to include("Revision: 6ee72f00")
      end
    end
  end
end
