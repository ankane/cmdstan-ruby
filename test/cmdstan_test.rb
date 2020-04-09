require_relative "test_helper"

class CmdStanTest < Minitest::Test
  def test_works
    # use temp directory since it creates files
    stan_file = "#{Dir.mktmpdir}/bernoulli.stan"
    File.write(stan_file, File.read("test/support/bernoulli.stan"))
    model = CmdStan::Model.new(stan_file: stan_file)

    assert_equal "bernoulli", model.name
    assert model.stan_file.end_with?("bernoulli.stan")
    assert model.exe_file.end_with?("bernoulli")
    assert_match "y ~ bernoulli(theta);", model.code

    data = {"N" => 10, "y" => [0, 1, 0, 0, 0, 0, 0, 0, 0, 1]}
    fit = model.sample(chains: 5, data: data, seed: 123)

    expected_names = %w(lp__ accept_stat__ stepsize__ treedepth__ n_leapfrog__ divergent__ energy__ theta)
    assert_equal expected_names, fit.column_names
    assert_equal 1000, fit.draws
    sample = fit.sample

    skip "Different results" if ENV["TRAVIS"]

    assert_in_delta -7.02513, sample[0][0][0]
    assert_in_delta -6.81299, sample[999][4][0]

    summary = fit.summary
    assert_in_delta -7.253620, summary["lp__"]["Mean"]
    assert_in_delta 0.250001, summary["theta"]["Mean"]

    mle = model.optimize(data: data, seed: 123)
    assert_equal ["lp__", "theta"], mle.column_names
    assert_in_delta -5.00402, mle.optimized_params["lp__"]
    assert_in_delta 0.2, mle.optimized_params["theta"]
  end
end
