# Benchmarks

Comparing [Dekkonot's bitbuffer](https://github.com/Dekkonot/bitbuffer), [Anaminus' bitbuf](https://github.com/Anaminus/roblox-library/tree/master/modules/Bitbuf) and rstk's bitbuffer.

## Run

1. Generate the benchmarks using the provided lua 5.3 script [`generate.lua`](generate.lua). Requires [`curl`](https://curl.se/).
2. Build the place file using [`benchmarks.project.json`](../benchmarks.project.json)
3. Hit run in Roblox Studio or use [run-in-roblox](https://github.com/rojo-rbx/run-in-roblox).

## Results

TODO: Unaligned benchmarks, Serializationj

#### WriteInt16
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.2880 | 0.3211 | 12.17x |
| Anaminus | Aligned | | 0.3661 | 0.3970 | 9.57x |
| Dekkonot | Aligned | | 3.5039 | 3.5090 | 1.00x |

#### ReadInt16
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.1736 | 0.1945 | 9.76x |
| Anaminus | Aligned | | 0.3172 | 0.3328 | 5.34x |
| Dekkonot | Aligned | | 1.6949 | 1.7624 | 1.00x |

---

#### WriteInt32
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.1826 | 0.2132 | 20.00x |
| Anaminus | Aligned | | 0.3415 | 0.3410 | 10.70x |
| Dekkonot | Aligned | | 3.6524 | 3.6550 | 1.00x |

#### ReadInt32
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.1200 | 0.1206 | 14.64x |
| Anaminus | Aligned | | 0.2995 | 0.3257 | 5.87x |
| Dekkonot | Aligned | | 1.7568 | 1.8839 | 1.00x |

---

#### WriteUInt16
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.2186 | 0.2266 | 2.86x |
| Anaminus | Aligned | | 0.2745 | 0.2900 | 2.28x |
| Dekkonot | Aligned | | 0.6252 | 0.6474 | 1.00x |

#### ReadUInt16
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.1605 | 0.2257 | 1.85x |
| Anaminus | Aligned | | 0.2011 | 0.2178 | 1.47x |
| Dekkonot | Aligned | | 0.2962 | 0.2840 | 1.00x |

---

#### WriteUInt32
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.1301 | 0.1400 | 8.02x |
| Anaminus | Aligned | | 0.3381 | 0.3582 | 3.09x |
| Dekkonot | Aligned | | 1.0440 | 1.0606 | 1.00x |

#### ReadUInt32
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.1134 | 0.1338 | 3.83x |
| Anaminus | Aligned | | 0.2172 | 0.2396 | 2.00x |
| Dekkonot | Aligned | | 0.4343 | 0.4573 | 1.00x |

---

#### WriteFloat32
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.2340 | 0.2442 | 4.79x |
| Anaminus | Aligned | | 1.1199 | 1.3312 | 1.00x |
| Dekkonot | Aligned | | 0.5783 | 0.6004 | 1.94x |

#### ReadFloat32
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.2013 | 0.2203 | 4.99x |
| Anaminus | Aligned | | 1.0047 | 1.1486 | 1.00x |
| Dekkonot | Aligned | | 0.3844 | 0.4067 | 2.61x |

---

#### WriteFloat64
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.7021 | 0.8278 | 1.69x |
| Anaminus | Aligned | | 1.1259 | 1.4201 | 1.05x |
| Dekkonot | Aligned | | 1.1871 | 1.1850 | 1.00x |

#### ReadFloat64
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.5786 | 0.6058 | 3.19x |
| Anaminus | Aligned | | 1.8480 | 2.1159 | 1.00x |
| Dekkonot | Aligned | | 0.7013 | 0.7978 | 2.64x |

---

#### WriteStringL10
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.2565 | 0.2936 | 1.71x |
| Dekkonot | Aligned | | 0.4390 | 0.4787 | 1.00x |

#### ReadStringL10
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.5820 | 0.7527 | 1.00x |
| Dekkonot | Aligned | | 0.4396 | 0.4701 | 1.32x |

---

#### WriteStringL100
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.6576 | 0.8280 | 6.76x |
| Dekkonot | Aligned | | 4.4478 | 4.6720 | 1.00x |

#### ReadStringL100
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 1.0369 | 1.1755 | 2.76x |
| Dekkonot | Aligned | | 2.8577 | 3.1126 | 1.00x |

---

#### WriteStringL1000
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 3.9900 | 4.8608 | 10.36x |
| Dekkonot | Aligned | | 41.3373 | 44.2775 | 1.00x |

#### ReadStringL1000
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 9.3274 | 10.6644 | 2.88x |
| Dekkonot | Aligned | | 26.8966 | 31.6431 | 1.00x |

---

#### WriteBytesL10
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.1369 | 0.1441 | 1.29x |
| Anaminus | Aligned | | 0.1762 | 0.1847 | 1.00x |

#### ReadBytesL10
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.1883 | 0.1968 | 1.00x |
| Anaminus | Aligned | | 0.1544 | 0.1741 | 1.22x |

---

#### WriteBytesL100
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.3619 | 0.3748 | 2.17x |
| Anaminus | Aligned | | 0.7840 | 0.8163 | 1.00x |

#### ReadBytesL100
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.3888 | 0.6210 | 1.13x |
| Anaminus | Aligned | | 0.4404 | 0.5228 | 1.00x |

---

#### WriteBytesL1000
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 5.2299 | 5.2866 | 1.68x |
| Anaminus | Aligned | | 8.7893 | 8.9761 | 1.00x |

#### ReadBytesL1000
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 4.4946 | 5.5968 | 1.06x |
| Anaminus | Aligned | | 4.7514 | 5.9678 | 1.00x |

---

#### WriteBool
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.1412 | 0.1634 | 2.92x |
| Anaminus | Aligned | | 0.2183 | 0.2293 | 1.89x |
| Dekkonot | Aligned | | 0.4117 | 0.4350 | 1.00x |

#### ReadBool
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.1035 | 0.1298 | 2.65x |
| Anaminus | Aligned | | 0.2000 | 0.2081 | 1.37x |
| Dekkonot | Aligned | | 0.2745 | 0.2864 | 1.00x |

---

#### WriteChar
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.1752 | 0.1878 | 1.39x |
| Anaminus | Aligned | | 0.2434 | 0.2599 | 1.00x |
| Dekkonot | Aligned | | 0.1652 | 0.1776 | 1.47x |

#### ReadChar
| Author | Alignment | | 50th % | Average | Delta |
| :----- | --------- | | :----: | :-----: | ----: |
| rstk | Aligned | | 0.1026 | 0.1199 | 1.66x |
| Anaminus | Aligned | | 0.1701 | 0.1950 | 1.00x |
| Dekkonot | Aligned | | 0.0709 | 0.0715 | 2.40x |
