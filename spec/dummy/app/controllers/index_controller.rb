class IndexController < ApplicationController
  def index
    flash_messenger.info "This is an :info message"
    render :index, locals: { flash_messenger: flash_messenger }
  end
end
