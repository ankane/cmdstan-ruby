from cmdstanpy import CmdStanModel, install_cmdstan

install_cmdstan()

model = CmdStanModel(stan_file='test/support/bernoulli.stan')
data = {"N": 10, "y": [0,1,0,0,0,0,0,0,0,1]}
fit = model.sample(chains=5, cores=1, data=data, seed=123)
print('sample')
print(fit.sample)
print('summary')
print(fit.summary())

mle = model.optimize(data=data, seed=123)
print('optimized_params_dict')
print(mle.optimized_params_dict)
