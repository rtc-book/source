import matplotlib.pyplot as plt
import numpy as np

def insert_sort(T):
	T_trace = [T.copy(),T.copy()]
	for i in range(1,len(T)):
		key = T[i]
		j = i - 1
		while (j >= 0 and T[j] > key):
			T[j+1] = T[j]
			j = j - 1
		T[j+1] = key
		T_trace.append(T.copy())
	T_trace.append(T.copy())
	return T,T_trace

def sort_order(T_trace):
	T_trace_order = []
	for i,T_i in enumerate(T_trace):
		sorter = np.argsort(T_i)
		T_trace_order.append(
			sorter[
				np.searchsorted(T_i, T_trace[0], sorter=sorter)
			]
		)
	return T_trace_order

T = [88,14,34,62,90,16,55,19,48,73]

Tp,T_trace = insert_sort(T)
T_trace_order = sort_order(np.array(T_trace))

plt.plot(
	T_trace_order,
	linewidth=5,
	solid_capstyle='round',
	solid_joinstyle='round'
)
plt.show()
