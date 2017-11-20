import random

import numpy as np
try:
    from numpy.fft import using_mklfft
except:
    using_mklfft = None
from numpy.testing import assert_array_almost_equal, TestCase, run_module_suite


def fft1(x):
    L = len(x)
    phase = -2j * np.pi * (np.arange(L) / float(L))
    phase = np.arange(L).reshape(-1, 1) * phase
    return np.sum(x * np.exp(phase), axis=1)


class TestFFT1D(TestCase):
    def test_basic(self):
        rand = np.random.random
        x = rand(30) + 1j * rand(30)
        assert_array_almost_equal(fft1(x), np.fft.fft(x))

    def test_change_array(self):
        rand = np.random.random
        x = rand(10) + 1j * rand(10)
        for n in range(5, 15):
            xx = x.copy()
            np.fft.fft(x, n)
            assert_array_almost_equal(x, xx)

    def test_narg(self):
        rand = np.random.random
        x = rand(10) + 1j * rand(10)
        for n in range(5, 15):
            if n < len(x): # crop
                y = x[:n]
            else: # pad with zeros
                y = list(x) + ((n - len(x)) * [0])
            self.assertEqual(n, len(y))
            z = np.fft.fft(x, n)
            self.assertEqual(n, len(z))
            assert_array_almost_equal(fft1(y), z)

    def test_dtype(self):
        for t1, t2 in [(np.float32, 'complex64'),
                       (np.float64, 'complex128'),
                       (np.complex64, 'complex64'),
                       (np.complex128, 'complex128')]:
            a = np.exp(2j * np.pi * np.arange(8) / 8)
            a = a.astype(t1)
            b = np.fft.fft(a)
            assert_array_almost_equal(fft1(a), b)
            if using_mklfft:
                self.assertEqual(b.dtype.name, t2)
            else:
                self.assertEqual(b.dtype.name, 'complex128')

    def test_sizes(self):
        for n in [1, 2, 3, 4, 5, 8, 16, 20, 31, 32, 127, 128, 129]:
            x = np.random.random(n) + 1j * np.random.random(n)
            assert_array_almost_equal(fft1(x), np.fft.fft(x))

    def test_ifft(self):
        for n in range(2, 32):
            x = np.random.random(n) + 1j * np.random.random(n)
            y = np.fft.fft(x)
            z = np.fft.ifft(y)
            assert_array_almost_equal(x, z)

    def test_rfft(self):
        x = np.fft.rfft([0, 1, 0, 0])
        y = np.array([1, -1j, -1])
        assert_array_almost_equal(x, y)

        x = np.fft.rfft([0, 1, 0], n=4)
        assert_array_almost_equal(x, y)

    def test_irfft(self):
        for x, y in [([1, 0], [0.5, 0.5]),
                     ([1, -1j, -1], [0, 1, 0, 0]),
                     ([2, 0, 2, 0], [1, 0, 0, 1, 0, 0]),
                     ]:
            assert_array_almost_equal(np.fft.irfft(x), y)

        for m in range(2, 20):
            x = [1] + ([0] * (m - 1))
            n = 2 * (m - 1)
            y = [1.0 / n] * n
            assert_array_almost_equal(np.fft.irfft(x), y)
            assert_array_almost_equal(np.fft.irfft(x, n=n), y)

        for n in range(2, 32):
            x = np.random.random(n)
            y = np.fft.rfft(x)
            z = np.fft.irfft(y, n=n)
            assert_array_almost_equal(x, z)

    def test_2d_array(self):
        m, n = 5, 3
        a = np.random.randn(m, n) + 1j * np.random.randn(m, n)
        b = np.array([np.fft.fft(a[i]) for i in range(m)])
        assert_array_almost_equal(np.fft.fft(a), b)

        b = np.swapaxes(a, 0, 1)
        c = np.fft.fft(b)
        d = np.swapaxes(c, 0, 1)
        assert_array_almost_equal(np.fft.fft(a, axis=0), d)


class TestFFTND(TestCase):
    def test_basic_2d(self):
        a = np.random.randn(5, 3) + 1j * np.random.randn(5, 3)
        b = a.copy()
        for i in range(2):
            b = np.array(np.fft.fft(b, axis=i))
        assert_array_almost_equal(np.fft.fftn(a), b)

    def test_3d_1d(self):
        a = np.random.randn(5, 3, 7) + 1j * np.random.randn(5, 3, 7)
        for axis in range(3):
            b = np.array(np.fft.fft(a, axis=axis))
            assert_array_almost_equal(np.fft.fftn(a, axes=(axis,)), b)

    def test_3d_2d(self):
        a = np.random.randn(5, 3, 7) + 1j * np.random.randn(5, 3, 7)
        b = a.copy()
        axes = (1, 2)
        for i in axes:
            b = np.array(np.fft.fft(b, axis=i))
        assert_array_almost_equal(np.fft.fftn(a, axes=axes), b)

    def test_nd_dim(self):
        for nd in range(1, 9):
            args = tuple(nd * [3])
            a = np.random.randn(*args) + 1j * np.random.randn(*args)
            for dim in range(1, nd + 1):
                b = a.copy()
                axes = range(nd - dim, nd)
                for i in axes:
                    b = np.array(np.fft.fft(b, axis=i))
                assert_array_almost_equal(np.fft.fftn(a, axes=axes), b)

    def test_nd_axes(self):
        for nd in range(1, 9):
            args = tuple(nd * [3])
            a = np.random.randn(*args) + 1j * np.random.randn(*args)
            for dim in range(1, nd + 1):
                b = a.copy()
                axes = random.sample(range(nd), dim)
                for i in axes:
                    b = np.array(np.fft.fft(b, axis=i))
                assert_array_almost_equal(np.fft.fftn(a, axes=axes), b)

    def test_nd_shape(self):
        for nd in range(1, 9):
            args = tuple(nd * [3])
            a = np.random.randn(*args) + 1j * np.random.randn(*args)
            for dim in range(1, nd + 1):
                b = a.copy()
                axes = random.sample(range(nd), dim)
                shape = [random.randint(2, 5) for dum in range(dim)]
                for i in range(dim):
                    b = np.array(np.fft.fft(b, n=shape[i], axis=axes[i]))
                assert_array_almost_equal(np.fft.fftn(a, s=shape, axes=axes), b)

    def test_basic_nd(self):
        for nd in range(1, 9):
            args = tuple(nd * [3])
            a = np.random.randn(*args) + 1j * np.random.randn(*args)
            b = a.copy()
            for i in range(nd):
                b = np.array(np.fft.fft(b, axis=i))
            assert_array_almost_equal(np.fft.fftn(a), b)

    def test_ifftn(self):
        for nd in range(1, 9):
            args = tuple(nd * [3])
            x = np.random.randn(*args) + 1j * np.random.randn(*args)
            y = np.fft.fftn(x)
            z = np.fft.ifftn(y)
            assert_array_almost_equal(x, z)


if __name__ == "__main__":
    run_module_suite()
