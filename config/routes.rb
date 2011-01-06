ClearanceDatamapper::Application.routes.draw do
  
  resources :password,
    :only => [:new, :create]
    
  resources :session, :only => [:new, :create, :destroy]
  
  match '/login' => 'session#new', :as => :login 
  match '/logout' => 'session#destroy', :as => :logout

end
