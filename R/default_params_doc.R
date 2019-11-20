#' This function does nothing. It is intended to inherit is parameters'
#' documentation.
#' @param a_abstol something
#' @param a_reltol something
#' @param abstol absolute error tolerance for
#' the numerical integration using deSolve.
#' @param atol absolute error tolerance for
#' the numerical integration using deSolve.
#' @param account_name something
#' @param after something
#' @param age the age of the tree.
#' @param alpha something
#' @param alpha0 something
#' @param b the number of simultaneous births on a given branching time.
#' @param brts A set of branching times of a phylogeny.
#' @param brts_precision set the level of approximation on the branching times.
#' @param changeloglikifnoconv something
#' @param checked_functions something
#' @param colormap something
#' @param cond sets the conditioning
#' \itemize{
#'  \item cond = 0: no conditioning;
#'  \item cond = 1: conditioning on stem or crown age
#'   and non-extinction of the phylogeny;
#'  \item cond = 2: like cond = 1 but forces at least one visible multiple
#'  event in the phylogeny
#' }
#' @param data_folder The data folder insider the project folder.
#' @param debug_mode If TRUE allows to run even when there are errors and
#'  expose them.
#' @param empty_pp empty pp matrix. See \code{pp}.
#' @param empty_qq empty qq matrix. See \code{qq}.
#' @param empty_mat an empty matrix
#' @param eq the equation approach you want to use. It can be "q_eq" for the
#'  Q-equation of "p_eq" for the P-equation.
#' @param expr and expression
#' @param fortran Set it to TRUE if you want to use FORTRAN routine.
#' @param func a function
#' @param function_name function name
#' @param function_names function names
#' @param functions_names function names
#' @param idparsfix something
#' @param idparsopt the ids of the parameters that must be optimized.
#'   The ids are defined as follows:
#'   \itemize{
#'     \item pars[1] is lambda, the sympatric speciation rate;
#'     \item pars[2] is mu, the extinction rate;
#'     \item pars[3] is nu, the multiple allopatric speciation trigger rate;
#'     \item pars[4] is q, the single-lineage speciation probability_
#'   }
#' @param initparsopt something
#' @param init_probs initial probabilities
#' @param initprobs initial probabilities
#' @param init_n_lineages the number of lineages at time equals zero.
#' @param input_trees_path Path to \code{.trees} file.
#' @param input_xml something
#' @param interval_max something
#' @param interval_min something
#' @param iterations something
#' @param k the number of visible species in the phylogeny at a given time.
#' @param lambda the sympatric speciation rate.
#' @param lambda_limit Upper limit to lambda estimations.
#' @param likelihood the likelihood
#' @param l_matrix the l-table
#' @param loglik_function the loglik function
#' @param loglik_functions the loglik_functions you want to use
#' @param logs something
#' @param log_nu_mat logarithmic nu-matrix, used for condprob
#' @param log_q_mat logarithmic q-matrix, used for condprob
#' @param lx it is the number of ODEs considered for the computation.
#' @param lx0 something
#' @param lx_top maximum lx to produce pre-calculated matrices for condprob
#' @param m1 a matrix keeping track of columns
#' @param m2 a matrix keeping track of rows
#' @param m1_mat a matrix keeping track of columns
#' @param m2_mat a matrix keeping track of rows
#' @param mm indexes of missing species
#' @param matrices matrices
#' @param matrix a matrix
#' @param matrix_a The A matrix from the theory that represents the ODE system.
#' @param matrix_builder function used to build the transition matrix.
#' Default option is \code{hyper_a_hanno}
#' @param max_iter Sets the maximum number of iterations in the optimization
#' @param max_k something
#' @param max_number_of_species something
#' @param max_repetitions something
#' @param max_sims something
#' @param maxit maximum number of subplex iterations
#' @param maxiter maximum number of subplex iterations
#' @param mbd_lambda something
#' @param message a message
#' @param methode
#'   specifies how the integration must be performed:
#'   \itemize{
#'     \item \code{lsodes}: use \code{lsodes} and \code{deSolve::ode}
#'     \item \code{ode45}: use \code{ode45} and \code{deSolve::ode}
#'     \item \code{lsoda}: use \code{lsoda} and \code{deSolve::ode}
#'   }
#' @param minimum_multiple_births minimum amount of multiple births
#' that have to be present in the simulated phylogeny.
#' @param missnumspec The number of species that are in the clade,
#'   but missing in the phylogeny.
#' @param models the models you want to use to define the likelihood
#' @param mu the extinction rate.
#' @param mu_limit Upper limit to mu estimations.
#' @param mutation_rate something
#' @param n_0 the number of lineages at time equals zero.
#' @param n_0s starting number of lineages for all the clades
#' @param n_species number of species.
#' @param n_sims number of simulations
#' @param n_steps something
#' @param n_subs something
#' @param nu the multiple allopatric speciation trigger rate.
#' @param nu_limit Upper limit to nu estimations.
#' @param nu_matrix matrix for the nu component. Component {m,n} is equal to
#'  choose(n, m - n) x q ^ (m - n) x (1 - q) ^ (2 * n - m)
#' @param optimmethod optimization routine: choose between subplex and simplex
#' @param optim_ids ids of the parameters you want to optimize.
#' @param pp the matrix p_{n1, n2}
#' @param pp2 the matrix p_{n1, n2}, with an empty frame
#' @param parms some parameters to pass on the ode function
#' @param parmsvec parameters to pass to the FORTRAN scripts
#' @param params transition matrix for the rhs of the ode system.
#' @param pars vector of parameters:
#' \itemize{
#'   \item pars[1] is lambda, the sympatric speciation rate;
#'   \item pars[2] is mu, the extinction rate;
#'   \item pars[3] is nu, the multiple allopatric speciation trigger rate;
#'   \item pars[4] is q, the single-lineage speciation probability;
#' }
#' @param pars_transform something
#' @param pars_transformed parameters of the likelihood functions, transformed
#' according to y = x / (1 + x)
#' @param parsfix the values of the parameters that should not be optimized.
#' @param parsvec vector of paramters for the FORTRAN subroutine.
#' @param pc conditional probability
#' @param pool the pool of living species at a given time
#' @param precision something
#' @param printit something
#' @param print_errors something
#' @param project_folder the folder when you want to save data and results
#' @param pvec a vector of probabilities P
#' @param q_t the q_vector in time
#' @param q_vector the \code{Q} vector from
#' 'Etienne et al. 2012 - Proc. R. Soc. B'.
#' @param q the single-lineage speciation probability at a triggered event.
#' @param qq the matrix q_{m1, m2}
#' @param qq2 the matrix q_{m1, m2}, with an empty frame
#' @param quantiles_choice something
#' @param qvec a vector of probabilities Q
#' @param q_threshold adds a threshold for the evaluation of q. This is due
#' because you never want \code{q} to actually be equal to zero or one.
#' @param recursive something
#' @param rtol relative error tolerance for
#' the numerical integration using deSolve.
#' @param reltol relative error tolerance for
#' the numerical integration using deSolve.
#' @param res something
#' @param results mle results
#' @param results_folder The results folder insider the project folder.
#' @param rhs_function a function for the right hand side of the differential
#'  equation
#' @param runmod FORTRAN subroutine's option
#' @param s the seed
#' @param saveit do you want to save the results?
#' @param safety_checks TRUE if you want the parameters to be limited to a
#'  realistic, but not infinite, parameter space
#' @param sample_interval something
#' @param seed the seed
#' @param sequence_length something
#' @param sim the results of a sim run
#' @param sim_pars vector of parameters:
#' \itemize{
#'   \item id == 1 corresponds to lambda (speciation rate)
#'   \item id == 2 corresponds to mu (extinction rate)
#'   \item id == 3 corresponds to nu (multiple speciation trigger rate)
#'   \item id == 4 corresponds to q (single-lineage speciation probability)
#' }
#' @param sim_phylo something
#' @param starting_seed the seed to start from
#' @param subsamp something
#' @param sum_probs_1 vector of probability sums
#' @param sum_probs_2 vector of probability sums
#' @param t time
#' @param tcrit the time you don't want to exceed in the integration
#' @param times vector of times
#' @param tvec vector of times
#' @param t1 something
#' @param t2 something
#' @param t_0 starting time
#' @param t_0s starting time for each clade
#' @param time_interval a time interval
#' @param tips_interval sets tips boundaries constrain on simulated dataset.
#'   It works only if cond == 1, otherwise it must be set to c(0, Inf).
#' @param tol something
#' @param tr a phylogeny of class \code{phylo}
#' @param transition_matrix something
#' @param trparsfix something
#' @param trparsopt something
#' @param true_pars true parameter values when running the ml process.
#' @param values something
#' @param vector a vector
#' @param verbose choose if you want to print the output or not
#' @param x something
#' @param x_name something
#' @param x_splits something
#' @param y something
#' @param y_name something
#' @param y_splits something
#' @param z something
#' @param z_name something
#' @param start_pars starting parameter values for the ml process.
#' @author Documentation by Giovanni Laudanno,
#'   use of this function by Richel J.C. Bilderbeek
#' @note This is an internal function, so it should be marked with
#'   \code{@noRd}. This is not done, as this will disallow all
#'   functions to find the documentation parameters
default_params_doc <- function(
  a_abstol,
  a_reltol,
  atol,
  abstol,
  account_name,
  after,
  age,
  alpha,
  alpha0,
  b,
  brts,
  brts_precision,
  changeloglikifnoconv,
  checked_functions,
  colormap,
  cond,
  data_folder,
  debug_mode,
  empty_mat,
  empty_pp,
  empty_qq,
  eq,
  expr,
  fortran,
  func,
  function_name,
  function_names,
  functions_names,
  idparsfix,
  idparsopt,
  initparsopt,
  init_n_lineages,
  initprobs,
  init_probs,
  input_trees_path,
  input_xml,
  interval_max,
  interval_min,
  iterations,
  k,
  lambda,
  lambda_limit,
  likelihood,
  l_matrix,
  loglik_function,
  loglik_functions,
  logs,
  log_nu_mat,
  log_q_mat,
  lx,
  lx0,
  lx_top,
  m1,
  m2,
  m1_mat,
  m2_mat,
  mm,
  matrices,
  matrix,
  matrix_a,
  matrix_builder,
  max_iter,
  max_k,
  max_number_of_species,
  max_repetitions,
  max_sims,
  maxit,
  maxiter,
  mbd_lambda,
  message,
  methode,
  minimum_multiple_births,
  missnumspec,
  models,
  mu,
  mu_limit,
  mutation_rate,
  n_0,
  n_0s,
  n_species,
  n_sims,
  n_steps,
  n_subs,
  nu,
  nu_limit,
  nu_matrix,
  optimmethod,
  optim_ids,
  pp,
  pp2,
  parms,
  parmsvec,
  params,
  pars,
  pars_transform,
  pars_transformed,
  parsfix,
  parsvec,
  pc,
  pool,
  precision,
  print_errors,
  printit,
  project_folder,
  pvec,
  q,
  qq,
  qq2,
  q_t,
  q_vector,
  q_threshold,
  quantiles_choice,
  qvec,
  recursive,
  rtol,
  reltol,
  res,
  results,
  results_folder,
  rhs_function,
  runmod,
  s,
  safety_checks,
  saveit,
  seed,
  sample_interval,
  sequence_length,
  sim,
  sim_pars,
  sim_phylo,
  start_pars,
  starting_seed,
  subsamp,
  sum_probs_1,
  sum_probs_2,
  t,
  tcrit,
  times,
  tvec,
  t1,
  t2,
  t_0,
  t_0s,
  tips_interval,
  time_interval,
  tol,
  tr,
  transition_matrix,
  trparsfix,
  trparsopt,
  true_pars,
  values,
  vector,
  verbose,
  x,
  x_name,
  x_splits,
  y,
  y_name,
  y_splits,
  z,
  z_name
) {
  # Nothing
}
