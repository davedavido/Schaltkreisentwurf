import numpy as np
import matplotlib.pyplot as plt

x = np.arange(start =1024,stop = 14336,step =1) #0.25, 3.5
y = 1/x * 2**12

y_approx = np.genfromtxt('Verilog/Output.txt')/2**12

error = np.abs(y_approx-y)
np.savetxt('Verilog/input.txt',x, delimiter= '\n', fmt='%d')

x = x/2**12
fig, ax = plt.subplots(1,3, figsize= (20,11))

ax[0].plot(x,y)
ax[0].set_title('$\dfrac{1}{x}$')
ax[1].plot(x,y_approx)
ax[1].set_title('~ $\dfrac{1}{x}$, n = 5')
ax[2].plot(x,error)
ax[2].set_title('Error')
plt.savefig('Compare_n_6.png')


