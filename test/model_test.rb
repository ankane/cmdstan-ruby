require_relative "test_helper"

class ModelTest < Minitest::Test
  def test_works
    # use temp directory since it creates files
    stan_file = "#{Dir.mktmpdir}/bernoulli.stan"
    File.write(stan_file, File.read("test/support/bernoulli.stan"))
    model = CmdStan::Model.new(stan_file: stan_file)

    assert_equal "bernoulli", model.name
    assert model.stan_file.end_with?("bernoulli.stan")
    if windows?
      assert model.exe_file.end_with?("bernoulli.exe")
    else
      assert model.exe_file.end_with?("bernoulli")
    end
    assert_match "y ~ bernoulli(theta);", model.code

    data = {"N" => 10, "y" => [0, 1, 0, 0, 0, 0, 0, 0, 0, 1]}
    fit = model.sample(chains: 5, data: data, seed: 123)

    expected_names = %w(lp__ accept_stat__ stepsize__ treedepth__ n_leapfrog__ divergent__ energy__ theta)
    assert_equal expected_names, fit.column_names
    assert_equal 1000, fit.draws
    sample = fit.sample
    # different results on different machines with same seed
    assert_in_delta(-7.26055, sample[0][0][0], 1)
    assert_in_delta(-7.26055, sample[999][4][0], 1)

    summary = fit.summary
    assert_equal 2, summary.size
    # different results on different machines with same seed
    assert_in_delta(-7.26055, summary["lp__"]["Mean"], 0.1)
    assert_in_delta(0.247379, summary["theta"]["Mean"], 0.1)

    mle = model.optimize(data: data, seed: 123)
    assert_equal ["lp__", "theta"], mle.column_names
    assert_in_delta(-5.00402, mle.optimized_params["lp__"])
    assert_in_delta(0.2, mle.optimized_params["theta"])

    # load model
    model = CmdStan::Model.new(exe_file: model.exe_file)
    fit = model.sample(chains: 5, data: data, seed: 123)
    assert_equal 1000, fit.draws
  end
end
