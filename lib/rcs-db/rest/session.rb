#
# Controller for the Sessions
#

require_relative '../push'

require 'digest/sha1'

module RCS
module DB

class SessionController < RESTController

  def index
    require_auth_level :admin

    return ok(SessionManager.instance.all)
  end
  
  def destroy
    require_auth_level :admin
    
    session_id = @params['_id']
    session = SessionManager.instance.get(session_id)
    return not_found if session.nil?
    return not_found unless SessionManager.instance.delete(session_id)

    PushManager.instance.notify('message', {rcpt: session[:user][:_id], text: 'You were disconnected by and admin'})

    Audit.log :actor => @session[:user][:name], :action => 'session.destroy', :desc => "Killed the session of the user '#{session[:user][:name]}'"

    return ok
  end

end

end #DB::
end #RCS::