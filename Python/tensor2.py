import tensorflow as tf

n_inputs  = 10
n_outputs = 10

x = tf.placeholder( size = (None, n_inputs) )
y = tf.placeholder( size = (None, n_outputs) )

net = x
net = tf.dense_layer( inputs     = net
                    , units      = 15
                    , activation = tf.nn.relu )

net = tf.dense_layer( inputs     = net
                    , units      = 10
                    , activation = tf.nn.relu )

out                              = net

loss      = tf.meansqaured.error(out, y)
optimizer = tf.train.rmsprop(0.001).minimize(loss)
