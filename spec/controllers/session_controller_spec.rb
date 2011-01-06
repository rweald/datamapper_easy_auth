require 'spec_helper'

describe SessionController do
  describe "GET new" do
    it "should be a success" do
      get :new
      response.should render_template("new")
    end
  end
end
