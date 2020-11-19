# CmdStan.rb

Bayesian inference for Ruby, powered by [CmdStan](https://github.com/stan-dev/cmdstan)

[![Build Status](https://github.com/ankane/cmdstan/workflows/build/badge.svg?branch=master)](https://github.com/ankane/cmdstan/actions)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'cmdstan'
```

Installation can take a few minutes as CmdStan downloads and builds.

## Getting Started

Create a Stan file, like `bernoulli.stan`

```stan
data {
  int<lower=0> N;
  int<lower=0,upper=1> y[N];
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  theta ~ beta(1,1);
  y ~ bernoulli(theta);
}
```

Compile the model

```ruby
model = CmdStan::Model.new(stan_file: "bernoulli.stan")
```

Fit the model

```ruby
data = {"N" => 10, "y" => [0, 1, 0, 0, 0, 0, 0, 0, 0, 1]}
fit = model.sample(data: data, chains: 5)
```

Summarize the results

```ruby
fit.summary
```

## Maximum Likelihood Estimation

```ruby
mle = model.optimize(data: data)
mle.optimized_params
```

## Credits

This library is modeled after the [CmdStanPy API](https://github.com/stan-dev/cmdstanpy).

## History

View the [changelog](https://github.com/ankane/cmdstan/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/cmdstan/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/cmdstan/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/ankane/cmdstan.git
cd cmdstan
bundle install
bundle exec ruby ext/cmdstan/extconf.rb
bundle exec rake test
```
