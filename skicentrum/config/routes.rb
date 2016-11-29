Rails.application.routes.draw do

  root 'map#show'

  get '/ski_resorts', to: 'skieur#ski_resorts'
  get '/ski_resorts_fac', to: 'skieur#ski_resorts_fac'
  get '/ski_resorts_reg', to: 'skieur#ski_resorts_reg'
  get '/ski_resorts_fac_reg', to: 'skieur#ski_resorts_fac_reg'
  get '/skiresort/:id' => 'resort#show', as: 'resort'

end
