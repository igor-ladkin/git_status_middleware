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

    it "appends git setup instruction to response if git is not installed" do
      allow(middleware).to receive(:git_installed?).and_return(false)

      _, _, response = subject
      expect(response.last).to include("Git is not installed. Install!")
    end

    it "appends git init instruction to response if git is not initialized" do
      allow(middleware).to receive(:git_initialized?).and_return(false)

      _, _, response = subject
      expect(response.last).to include("Git is not initialized. Initialize!")
    end
  end
end
