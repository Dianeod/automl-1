import theano
from theano import tensor as T
import numpy as np


def init_weights(shape):
    print("h0")
    """ Weight initialization """
    weights = np.asarray(np.random.randn(*shape) * 0.01, dtype=theano.config.floatX)
    print("h1")
    return theano.shared(weights)

def backprop(cost, params, lr=0.01):
    """ Back-propagation """
    print("h1")
    grads   = T.grad(cost=cost, wrt=params)
    updates = []
    print("h2")
    for p, g in zip(params, grads):
        updates.append([p, p - g * lr])
    return updates

def forwardprop(X, w_1, w_2):
    """ Forward-propagation """
    print("h3")
    h    = T.nnet.sigmoid(T.dot(X, w_1))  # The \sigma function
    print("h4")
    yhat = T.nnet.softmax(T.dot(h, w_2))  # The \varphi function
    return yhat


def buildModel(train_X,train_y,seed):
   print("h5")
   np.random.seed(seed)  
 
  # Symbols
   X = T.fmatrix()
   Y = T.fmatrix()
   print("h6")
   # Layers sizes
   x_size = train_X.shape[1]             # Number of input nodes: 4 features and 1 bias
   h_size = 256                          # Number of hidden nodes
   y_size = train_y.shape[1]             # Number of outcomes (3 iris flowers)
   w_1 = init_weights((x_size, h_size))  # Weight initializations
   w_2 = init_weights((h_size, y_size))
   print("h7")
   # Forward propagation
   yhat   = forwardprop(X, w_1, w_2)
   print("h8")
   # Backward propagation
   cost    = T.mean(T.nnet.categorical_crossentropy(yhat, Y))
   params  = [w_1, w_2]
   updates = backprop(cost, params)
   print("h9")
   # Train and predict
   train   = theano.function(inputs=[X, Y], outputs=cost, updates=updates, allow_input_downcast=True)
   pred_y  = T.argmax(yhat, axis=1)
   predict = theano.function(inputs=[X], outputs=pred_y, allow_input_downcast=True)
   print("h10")
   return(train,predict)


def fitModel(train_X,train_y,model):
    print("h11")
    for iter in range(10):
        print("h12")
        for i in range(len(train_X)):
            model(train_X[i: i + 1], train_y[i: i + 1]) 


def predictModel(test_X,model):
  return model(test_X)




