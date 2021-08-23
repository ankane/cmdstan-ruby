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

    # different results on different platforms with same seed
    if mac?
      assert_in_delta(-6.78375, sample[0][0][0])
      assert_in_delta(-6.77201, sample[999][4][0])
    # elsif windows?
    #   assert_in_delta -7.16416, sample[0][0][0]
    #   assert_in_delta -7.39386, sample[999][4][0]
    # else
    #   assert_in_delta -7.78223, sample[0][0][0]
    #   assert_in_delta -6.7773, sample[999][4][0]
    end

    summary = fit.summary
    if mac?
      assert_in_delta(-7.26055, summary["lp__"]["Mean"])
      assert_in_delta(0.247379, summary["theta"]["Mean"])
    # elsif windows?
    #   assert_in_delta -7.27114, summary["lp__"]["Mean"]
    #   assert_in_delta 0.247182, summary["theta"]["Mean"]
    # else
    #   assert_in_delta -7.271400, summary["lp__"]["Mean"]
    #   assert_in_delta 0.254981, summary["theta"]["Mean"]
    end

    mle = model.optimize(data: data, seed: 123)
    assert_equal ["lp__", "theta"], mle.column_names
    assert_in_delta(-5.00402, mle.optimized_params["lp__"])
    assert_in_delta(0.2, mle.optimized_params["theta"])
  end

  private

  def mac?
    RbConfig::CONFIG["host_os"] =~ /darwin/i
  end

  def windows?
    Gem.win_platform?
  end
end
