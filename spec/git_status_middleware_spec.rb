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
    it "returns the same status code for SUCCESSFUL request" do
      allow(app).to receive(:call).with(env).and_return([200, {"Content-Type" => "text/html"}, [response_body]])

      status, _, _ = middleware.call(env)
      expect(status).to eq 200
    end

    it "returns the same status code for UNSUCCESSFUL request" do
      allow(app).to receive(:call).with(env).and_return([404, {"Content-Type" => "text/html"}, [response_body]])

      status, _, _ = middleware.call(env)
      expect(status).to eq 404
    end
  end
end
