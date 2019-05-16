//
// Created by Daniel Strobusch on 2019-05-07.
//

import Darwin
import Accelerate

public class Matrix<T>: NdArray<T> {
    /// create an 2D NdArray from a plain array
    public convenience init(_ a: [[T]], order: Contiguous = .C) {
        guard let first = a.first else {
            self.init(empty: [1, 0], order: order)
            return
        }

        let rowCount = a.count
        let colCount = first.count
        self.init(empty: [rowCount, colCount], order: order)

        switch order {
        case .C:
            for i in 0..<rowCount {
                let row = a[i]
                assert(row.count == colCount, "\(row.count) == \(colCount) at row \(i)")
                memcpy(data + i * strides[0], row, colCount * MemoryLayout<T>.stride)
            }
        case .F:
            for i in 0..<rowCount {
                let row = a[i]
                assert(row.count == colCount, "\(row.count) == \(colCount) at row \(i)")
                // manual memcopy for strided data
                for j in 0..<colCount {
                    data[i * strides[0] + j * strides[1]] = row[j]
                }
            }
        }
    }

    public init(empty shape: [Int], order: Contiguous = .C) {
        assert(shape.count == 2,
            """
            Cannot create matrix with shape \(shape). Matrix must have two dimensions.
            """)
        super.init(empty: shape.isEmpty ? 0 : shape.reduce(1, *))
        reshape(shape, order: order)
    }

    /// creates a view on another array without copying any data
    public init(_ a: Matrix<T>) {
        super.init(a)
    }

    internal required init(empty count: Int) {
        super.init(empty: count)
    }

    public required convenience init(copy a: NdArray<T>) {
        assert(a.shape.count == 2,
            """
            Cannot create matrix with shape \(a.shape). Matrix must have two dimensions.
            Assertion failed while trying to copy \(a.debugDescription).
            """)
        self.init(empty: a.shape, order: a.isFContiguous ? .F : .C)
        a.copyTo(self)
    }

}

public extension Matrix where T == Double {
    var T: Matrix<T> {
        get {
            return transposed()
        }
    }

    func transposed() -> Matrix<T> {
        let out = Matrix<T>(empty: shape.reversed())
        transposed(out: out)
        return out
    }

    func transposed(out: Matrix<T>) {
        assert(shape == shape.reversed(),
            """
            Cannot transpose matrix with shape \(shape) to matrix with shape \(out.shape).
            Assertion failed while trying to transpose \(self.debugDescription) to \(out.debugDescription).
            """)
        // TODO test strides carefully
        vDSP_mtransD(data, strides[0], out.data, out.strides[0], vDSP_Length(shape[1]), vDSP_Length(shape[0]))
    }

    func solve(_ x: Vector<T>, out: Vector<T>? = nil) throws -> Vector<T> {
        let B = out ?? Vector(empty: x.shape[0])
        // TODO
        return B
    }

    func solve(_ x: Matrix<T>, out: Matrix<T>? = nil) throws -> Matrix<T> {
        let B = out ?? Matrix(empty: x.shape)
        // TODO
        return B
    }

    func inverted(out: Matrix<T>? = nil) throws -> Matrix<T> {
        let B = out ?? Matrix(empty: self.shape)
        // TODO
        return B
    }

}


public func *(A: Matrix<Double>, x: Vector<Double>) -> Vector<Double> {
    // TODO
    let y = Vector<Double>(empty: x.shape[0])
    return y
}

public func *(A: Matrix<Double>, B: Matrix<Double>) -> Matrix<Double> {
    // TODO
    let y = Matrix<Double>(empty: B.shape)
    return y
}

// TODO override for band/tridiag matrix

