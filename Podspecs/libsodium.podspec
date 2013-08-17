Pod::Spec.new do |s|
  s.name         = "libsodium"
  s.version      = "0.4.2"
  s.summary      = "Sodium is a portable, cross-compilable, installable, packageable, API-compatible version of NaCl."
  s.homepage     = "https://github.com/jedisct1/libsodium"
  s.license      = { :type => "BSD",
                     :text => <<-LICENSE
Copyright © 2013
Frank Denis <j at pureftpd dot org>

Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

                     LICENSE
  }

  s.author   = { "Frank Dennis" => "j@pureftpd.org" }
  s.source   = { :git => 'https://github.com/mochtu/libsodium-ios.git', :tag => '0.4.2' }
  
  s.osx.deployment_target = '10.6'

  s.header_mappings_dir = 'src/libsodium/include'
  
  s.source_files = 'src/libsodium/**/*.{c,h,data,S}'
  s.exclude_files =  '**/*try.*'

  defs = %w{ STDC_HEADERS HAVE_SYS_TYPES_H HAVE_SYS_STAT_H HAVE_STDLIB_H HAVE_STRING_H HAVE_MEMORY_H HAVE_STRINGS_H HAVE_INTTYPES_H HAVE_STDINT_H HAVE_UNISTD_H __EXTENSIONS__ _ALL_SOURCE _GNU_SOURCE _POSIX_PTHREAD_SEMANTICS _TANDEM_SOURCE HAVE_DLFCN_H HAVE_EMMINTRIN_H HAVE_TMMINTRIN_H HAVE_FENV_H NATIVE_LITTLE_ENDIAN HAVE_AMD64_ASM HAVE_TI_MODE HAVE_CPUID SODIUM_HAVE_TI_MODE }

  s.xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => "$(inherited) #{defs.join('=1 ')}=1" }
  end
