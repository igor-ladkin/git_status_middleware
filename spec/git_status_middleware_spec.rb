require "git_status_middleware"

describe GitStatusMiddleware do
  let(:middleware) { described_class.new(app) }
  let(:original_body) { "<html><body>Hello world!</body></html>" }
  let(:body_length) { "#{original_body.bytesize}" }
  let(:git_status) { instance_double GitStatus, to_html: "<p>Lé git</p>" }
  let(:app) do
    double "Some Application",
      call: [200, {"Content-Type" => "text/html", "Content-Length" => body_length }, [original_body]]
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
      expect(app).to receive(:call)
        .with(env)
        .and_return([200, {"Content-Type" => "text/html", "Content-Length" => body_length }, [original_body]])

      status, _, _ = subject
      expect(status).to eq 200
    end

    it "appends git status widget to the response body" do
      allow(middleware).to receive(:git_status).and_return(git_status)

      _, _, response = subject
      expect(response.join "").to include("Lé git")
    end

    it "updates content length header to consider widget length in bytes" do
      allow(middleware).to receive(:git_status).and_return(git_status)

      _, headers, _ = subject
      bytesize_diff = headers["Content-Length"].to_i - body_length.to_i
      expect(bytesize_diff).to eq(14)
    end

    it "returns the same status code and does not append widget for UNSUCCESSFUL request", :aggregate_failures do
      expect(app).to receive(:call)
        .with(env)
        .and_return([404, {"Content-Type" => "text/html", "Content-Length" => body_length }, [original_body]])

      status, _, response = subject
      expect(status).to eq 404
      expect(response.join "").not_to include("Lé git")
    end

    it "does not include git status widget if the request content type is different from HTML" do
      expect(app).to receive(:call)
        .with(env)
        .and_return([204, {"Content-Type" => "application/json", "Content-Length" => "0" }, [""]])

      _, _, response = subject
      expect(response.join "").not_to include("Lé git")
    end
  end
end
