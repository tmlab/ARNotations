# Way to go in Rails 3
#class CTMResponder < ActionController::Responder
#
#  def to_ctm
#    return
#  end
#
#end
#
#class TopicMapResponder < ActionController::Responder
#  include CTMResponder
#  include XTM2Responder
#end
#
#class ActionController::Base
#
#  protected
#
#  def responder
#    TopicMapResponder
#  end
#end
