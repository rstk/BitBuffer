Comparing [Dekkonot's bitbuffer](https://github.com/Dekkonot/bitbuffer), [Anaminus' bitbuf](https://github.com/Anaminus/roblox-library/tree/master/modules/Bitbuf) and rstk's bitbuffer.  

To run the benchmarks yourself:

1. Generate the benchmarks using the provided lua 5.3 script [`generate.lua`](generate.lua). Requires [`curl`](https://curl.se/).
2. Build the place file using [`benchmarks.project.json`](../benchmarks.project.json)
3. Hit run in Roblox Studio or use [run-in-roblox](https://github.com/rojo-rbx/run-in-roblox).

## Results (Aligned)

### ReadInt16
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.1783** | **0.1833** | **10.25x** |
| Anaminus | 0.3951 | 0.4558 | 4.63x |
| Dekkonot | 1.8282 | 2.0249 | 1.00x |
### WriteInt16
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.2282** | **0.2295** | **13.27x** |
| Anaminus | 0.4068 | 0.4324 | 7.44x |
| Dekkonot | 3.0286 | 3.1503 | 1.00x |

<br />

### ReadInt32
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.1444** | **0.1556** | **13.06x** |
| Anaminus | 0.3092 | 0.3235 | 6.10x |
| Dekkonot | 1.8861 | 2.0288 | 1.00x |
### WriteInt32
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.2196** | **0.2370** | **17.53x** |
| Anaminus | 0.3210 | 0.3478 | 11.99x |
| Dekkonot | 3.8498 | 4.0185 | 1.00x |

<br />

### ReadUInt16
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.1154** | **0.1284** | **2.38x** |
| Anaminus | 0.2557 | 0.2780 | 1.08x |
| Dekkonot | 0.2750 | 0.2990 | 1.00x |
### WriteUInt16
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.1585** | **0.1719** | **4.09x** |
| Anaminus | 0.3102 | 0.3538 | 2.09x |
| Dekkonot | 0.6476 | 0.6421 | 1.00x |

<br />

### ReadUInt32
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.1379** | **0.1580** | **2.59x** |
| Anaminus | 0.2530 | 0.2827 | 1.41x |
| Dekkonot | 0.3567 | 0.3921 | 1.00x |
### WriteUInt32
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.1607** | **0.1827** | **5.52x** |
| Anaminus | 0.3205 | 0.3566 | 2.77x |
| Dekkonot | 0.8866 | 1.0616 | 1.00x |

<br />

### ReadFloat32
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.2454** | **0.2518** | **4.47x** |
| Dekkonot | 0.3949 | 0.4395 | 2.78x |
| Anaminus | 1.0980 | 1.4336 | 1.00x |
### WriteFloat32
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.2347** | **0.2591** | **4.15x** |
| Dekkonot | 0.7166 | 0.7729 | 1.36x |
| Anaminus | 0.9733 | 1.1549 | 1.00x |

<br />

### ReadFloat64
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **Dekkonot** | **0.9273** | **1.0172** | **2.09x** |
| rstk | 0.9955 | 1.2550 | 1.95x |
| Anaminus | 1.9391 | 2.5082 | 1.00x |
### WriteFloat64
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.9983** | **1.1696** | **1.20x** |
| Anaminus | 1.1139 | 1.3207 | 1.08x |
| Dekkonot | 1.1984 | 1.3076 | 1.00x |

<br />

### ReadStringL10
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.2844** | **0.2922** | **1.63x** |
| Dekkonot | 0.4630 | 0.5032 | 1.00x |
### WriteStringL10
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.1687** | **0.1733** | **3.56x** |
| Dekkonot | 0.6011 | 0.6366 | 1.00x |

<br />

### ReadStringL100
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **1.2113** | **1.5511** | **2.34x** |
| Dekkonot | 2.8326 | 3.2811 | 1.00x |
### WriteStringL100
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.5274** | **0.5506** | **9.33x** |
| Dekkonot | 4.9183 | 7.5154 | 1.00x |

<br />

### ReadStringL1000
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **11.3303** | **13.2465** | **2.69x** |
| Dekkonot | 30.5080 | 91.9403 | 1.00x |
### WriteStringL1000
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **4.5967** | **5.7674** | **9.98x** |
| Dekkonot | 45.8587 | 71.1120 | 1.00x |

<br />

### ReadBytesL10
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.1290** | **0.1348** | **1.28x** |
| Anaminus | 0.1653 | 0.2054 | 1.00x |
### WriteBytesL10
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.0867** | **0.0932** | **1.80x** |
| Anaminus | 0.1558 | 0.1622 | 1.00x |

<br />

### ReadBytesL100
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.3912** | **0.5272** | **2.64x** |
| Anaminus | 1.0323 | 1.3461 | 1.00x |
### WriteBytesL100
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.5481** | **0.6393** | **1.57x** |
| Anaminus | 0.8585 | 0.9379 | 1.00x |

<br />

### ReadBytesL1000
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **4.2222** | **4.9854** | **1.12x** |
| Anaminus | 4.7375 | 5.4956 | 1.00x |
### WriteBytesL1000
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **4.4358** | **4.4320** | **1.82x** |
| Anaminus | 8.0603 | 8.2977 | 1.00x |

<br />

### ReadBool
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.1154** | **0.1131** | **2.65x** |
| Anaminus | 0.1833 | 0.1997 | 1.67x |
| Dekkonot | 0.3056 | 0.4233 | 1.00x |
### WriteBool
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.1318** | **0.1511** | **3.22x** |
| Anaminus | 0.2485 | 0.3247 | 1.71x |
| Dekkonot | 0.4244 | 0.4955 | 1.00x |

<br />

### ReadChar
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **Dekkonot** | **0.0790** | **0.0798** | **2.68x** |
| rstk | 0.0980 | 0.1101 | 2.16x |
| Anaminus | 0.2118 | 0.2449 | 1.00x |
### WriteChar
| Author &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp; 50th % | Average | Delta |
| :----- | -----: | ------: | ----: |
| **rstk** | **0.1540** | **0.1651** | **1.76x** |
| Dekkonot | 0.1732 | 0.2026 | 1.57x |
| Anaminus | 0.2714 | 0.3191 | 1.00x |

## Result (Unaligned)

TODO

## Notes

- Dekkonot's BitBuffer stores bits using 8-bit integers, while Anaminus's and rstk's BitBuffers use 32-bit integers.
- Dekkonot's BitBuffer supports more (including roblox-specific) data types out of the box.

### TODO

- [ ] Serialization
- [ ] Unaligned

