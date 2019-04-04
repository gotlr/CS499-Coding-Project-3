#' Neural Network algorithm using iterations.
#'
#' This neural network algorithm has one output and one hidden layer, and stops when max.iterations is reached.
#'
#' @param X.mat numeric feature matrix of size [n_observations x n_features].
#' @param y.vec numeric label vector of length n_observations.
#' @param max.iterations integer scalar greater than 1.
#' @param step.size numeric positive scalar.
#' @param n.hidden.units number of hidden units, greater than or equal to 1.
#' @param is.train logical vector of length n_observations, TRUE if the observation is for training, FALSE for validation
#'
#' @return result.list with named elements:
#' pred.mat, n_observations x max.iterations matrix of predicted values.
#' W.mat final weight matrix (n_features+1 x n.hidden.units).
#' v.vec final weight vector (n.hidden.units+1).
#' predict(testX.mat) a function that takes a test features matrix and returns a vector of predictions.
#'
#' @export
#'
#' @examples
NNetIteration <-
  function(X.mat,
           y.vec,
           max.iterations,
           step.size,
           n.hidden.units,
           is.train) {
    
    if (y.vec %in% c(-1,1))
      is.binary <- 1;
    else
      is.binary <- 0;
    X.mat <- X.mat[is.train,-1]
    y.train <- y.vec[is.train]
    n.obeservations <- nrow(X.mat)
    n.features <- ncol(X.mat)
    X.mean.vec <- colMeans(X.mat)
    
    X.std.vec <-
      sqrt(rowSums((t(X.mat) - X.mean.vec) ^ 2) / num.train)
    X.std.mat <- diag(num.feature) * (1 / X.std.vec)
    
    X.scaled.mat <- t((t(X.mat) - X.mean.vec) / X.std.vec)
    X.scaled.train <- X.scaled.mat
    pred.mat <- matrix(0, n.obeservations, max.iterations)
    W.mat <- matrix(runif(n.features * n.hidden.units, 0, 0.2),
                    n.features, n.hidden.units)
    
    v.vec <- runif(n.hidden.units, 0, 0.2)
    intercept.v <- rep(0, n.obeservations)
#    w.vec.iter <- runif(0,0.3)  
    
    sigmoid <- function(x){
      return(1/(1 + exp(-x)))
    }
    
    dsigmoid <- function(x){
      return(sigmoid(x) * (1 - sigmoid(x)))
    }
    
    for (iter.index in seq(max.iterations)){
      temp.a.mat <- X.scaled.train %*% W.mat  # n x u
      temp.z.mat <- sigmoid(temp.a.mat)  # n x u
      temp.b.vec <- temp.z.mat %*% v.vec + intercept.v # n x 1
      if (is.binary){
       ## temp.y.vec <- sigmoid(temp.b.vec)
        error <- sigmoid(-y.vec * temp.b.vec) * exp(-y.vec * temp.b.vec) * (-y.vec)
        pred.mat[,iter.index] <- temp.b.vec
      }else{
        error <- temp.b.vec - y.train
        pred.mat[,iter.index] <-  ifelse(sigmoid(temp.b.vec)>0.5, 1, 0)
      }
        v.vec <- v.vec - step.size * ((t(temp.z.mat) %*% (error)) / n.obeservations)
        W.mat <- W.mat - step.size * (t(X.scaled.train) %*% ((error) %*% t(v.vec) *
                                                               dsigmoid(temp.a.mat)) / n.obeservations)
        intercept.v <- intercept.v - step.size * mean(error)
    }
    W.mat <- rbind(-t(W.mat) %*% X.std.mat %*% X.mean.vec, t(t(W.mat) %*% X.std.mat))
    v.vec <- c(intercept.v, v.vec)
    
    result.list <- list(
      pred.mat = pred.mat,
      W.mat = W.mat,
      v.vec = v.vec,
      predict = function(testX.mat) {
        prediction.vec <- sigmoid(cbind(1, testX.mat) %*% W.mat) %*% v.vec
        return(prediction.vec)
      }
    )
    return(result.list)
  }