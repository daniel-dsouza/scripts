filetype on
filetype plugin on
filetype indent on

set tabstop=2 softtabstop=2 shiftwidth=2 expandtab
set number

autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()
