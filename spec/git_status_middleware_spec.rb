require "git_status_middleware"

describe GitStatusMiddleware do
  let(:middleware) { described_class.new(app) }
  let(:original_body) { "<html><body>Hello world!</body></html>" }
  let(:git_status) { double "GitStatus", render: "<p>Lé git</p>" }
  let(:app) do
    double "Some Application",
      call: [200, {"Content-Type" => "text/html", "Content-Length" => original_body.bytesize }, [original_body]]
  end

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
      allow(app).to receive(:call)
        .with(env)
        .and_return([200, {"Content-Type" => "text/html", "Content-Length" => original_body.bytesize }, [original_body]])

      status, _, _ = subject
      expect(status).to eq 200
    end

    it "returns the same status code for UNSUCCESSFUL request" do
      allow(app).to receive(:call)
        .with(env)
        .and_return([404, {"Content-Type" => "text/html", "Content-Length" => original_body.bytesize }, [original_body]])

      status, _, _ = subject
      expect(status).to eq 404
    end

    it "appends git status widget to the response body" do
      allow(middleware).to receive(:git_status).and_return(git_status)

      _, _, response = subject
      expect(response.join "").to include("Lé git")
    end

    it "updates content length header to consider widget length in bytes" do
      allow(middleware).to receive(:git_status).and_return(git_status)

      _, headers, _ = subject
      bytesize_diff = headers["Content-Length"] - original_body.bytesize
      expect(bytesize_diff).to eq(14)
    end
  end
end
