import scipy
import sys

if sys.platform.startswith('linux'):
    scipy.test('full')
