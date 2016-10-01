Rails.application.routes.draw do
  resources :terra_nova_test_benchmarks
  resources :terra_nova_tests
  resources :schools
  resources :parishes
  resources :employees
  resources :star_tests
  get 'static_pages/dashboard'

  resources :students
	root to: 'sessions#new'

	# these routes are for showing users a login form, logging them in, and logging them out.
  	get '/login' => 'sessions#new'
  	post '/login' => 'sessions#create'
  	get '/logout' => 'sessions#destroy'

	# These routes will be for signup. The first renders a form in the browse, the second will 
    # receive the form and create a user in our database using the data given to us by the user.
    get '/signup' => 'users#new'
    post '/users' => 'users#create'
end