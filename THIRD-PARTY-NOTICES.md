# Third-party notices

Core is MIT licensed and, with the exception below, is original work.

## VideoTrimmer

`Core/VideoClasses/VideoTrimmer/` contains `VideoTrimmer.swift` and
`VideoTrimmerThumb.swift`, from
[AndreasVerhoeven/VideoTrimmer](https://github.com/AndreasVerhoeven/VideoTrimmer),
copyright © 2020 Andreas Verhoeven, used under the MIT licence. `CoreVideoKit` uses it as the
trimming control behind `AssetTimelineView`.

```
MIT License

Copyright (c) 2020 Andreas Verhoeven

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## PryntTrimmerView

`Core/VideoClasses/PryntTrimmerView/` is from
[HHK-HHK/PryntTrimmerView](https://github.com/HHK1/PryntTrimmerView), copyright © 2017 Prynt,
used under the MIT licence. It is an alternative trimming control, not currently wired up; see
the note above `typealias Trimmer` in `AssetTimelineCell.swift`.

```
MIT License

Copyright (c) 2017 Prynt

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Dependency

`CoreVideoKit` depends on [joeypatino/Cabbage](https://github.com/joeypatino/Cabbage), a fork of
[VideoFlint/Cabbage](https://github.com/VideoFlint/Cabbage), copyright © 2018 Vito Zhang, MIT
licensed. It is resolved by SPM rather than vendored here.
