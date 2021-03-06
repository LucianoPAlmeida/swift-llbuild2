// This source file is part of the Swift.org open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors


import llbuild2

import CBLAKE3


public extension LLBDataID {
    init(blake3hash buffer: LLBByteBuffer, refs: [LLBDataID]) {
        var hasher = blake3_hasher()
        blake3_hasher_init(&hasher)

        for ref in refs {
            let content = ref.bytes
            blake3_hasher_update(&hasher, content, content.count)
        }
        buffer.withUnsafeReadableBytes { data in
            blake3_hasher_update(&hasher, data.baseAddress, data.count)
        }

        let hash = [UInt8](unsafeUninitializedCapacity: Int(BLAKE3_OUT_LEN)) { (hash, len) in
            len = Int(BLAKE3_OUT_LEN)
            blake3_hasher_finalize(&hasher, hash.baseAddress, len)
        }

        self.init(directHash: hash)
    }
}
