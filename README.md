# CmdStan.rb

Bayesian inference for Ruby, powered by [CmdStan](https://github.com/stan-dev/cmdstan)

[![Build Status](https://github.com/ankane/cmdstan-ruby/workflows/build/badge.svg?branch=master)](https://github.com/ankane/cmdstan-ruby/actions)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem "cmdstan"
```

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

Compile the model (this can take a few minutes the first time as CmdStan downloads and builds)

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

Load a compiled model

```ruby
model = CmdStan::Model.new(exe_file: "bernoulli")
```

Check out [Strata](https://github.com/ankane/strata) for shipping models

## Maximum Likelihood Estimation

```ruby
mle = model.optimize(data: data)
mle.optimized_params
```

## Reference

Check if CmdStan is installed

```ruby
CmdStan.cmdstan_installed?
```

Install CmdStan manually

```ruby
CmdStan.install_cmdstan
```

## Credits

This library is modeled after the [CmdStanPy API](https://github.com/stan-dev/cmdstanpy).

## History

View the [changelog](https://github.com/ankane/cmdstan-ruby/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/cmdstan-ruby/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/cmdstan-ruby/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/ankane/cmdstan-ruby.git
cd cmdstan-ruby
bundle install
bundle exec rake test
```
