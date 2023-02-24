local hwktheorems = [[
  \newtheorem{theorem}{Theorem}
  \newtheorem{definition}{Definition}
  \newtheorem{lemma}{Lemma}
  \newtheorem{claim}{Claim}
  \newtheorem{fact}{Fact}
  \newtheorem{corollary}{Corollary}

]]
local notestheorems = [[
\usepackage{thmtools}
\usepackage[framemethod=TikZ]{mdframed}

\theoremstyle{definition}
\mdfdefinestyle{mdbluebox}{%
	roundcorner = 10pt,
	linewidth=1pt,
	skipabove=12pt,
	innerbottommargin=9pt,
	skipbelow=2pt,
	nobreak=true,
	linecolor=blue,
	backgroundcolor=TealBlue!5,
}
\declaretheoremstyle[
	headfont=\sffamily\bfseries\color{MidnightBlue},
	mdframed={style=mdbluebox},
	headpunct={\\\\[3pt]},
	postheadspace={0pt}
]{thmbluebox}

\mdfdefinestyle{mdredbox}{%
	linewidth=0.5pt,
	skipabove=12pt,
	frametitleaboveskip=5pt,
	frametitlebelowskip=0pt,
	skipbelow=2pt,
	frametitlefont=\bfseries,
	innertopmargin=4pt,
	innerbottommargin=8pt,
	nobreak=true,
	linecolor=RawSienna,
	backgroundcolor=Salmon!5,
}
\declaretheoremstyle[
	headfont=\bfseries\color{RawSienna},
	mdframed={style=mdredbox},
	headpunct={\\\\[3pt]},
	postheadspace={0pt},
]{thmredbox}

\mdfdefinestyle{mdblackbox}{%
	linewidth=0.5pt,
	skipabove=12pt,
	frametitleaboveskip=5pt,
	frametitlebelowskip=0pt,
	skipbelow=2pt,
	frametitlefont=\bfseries,
	innertopmargin=4pt,
	innerbottommargin=8pt,
	nobreak=true,
	linecolor=black,
	backgroundcolor=RedViolet!5!gray!5,
}
\declaretheoremstyle[
	mdframed={style=mdblackbox},
	headpunct={\\\\[3pt]},
	postheadspace={0pt},
]{thmblackbox}
\declaretheorem[%
style=thmbluebox,name=Theorem,numberwithin=section]{theorem}
\declaretheorem[style=thmbluebox,name=Lemma,sibling=theorem]{lemma}
\declaretheorem[style=thmbluebox,name=Proposition,sibling=theorem]{proposition}
\declaretheorem[style=thmbluebox,name=Corollary,sibling=theorem]{corollary}
\declaretheorem[style=thmredbox,name=Example,sibling=theorem]{example}
\declaretheorem[style=thmblackbox,name=Algorithm,sibling=theorem]{algo}

\mdfdefinestyle{mdgreenbox}{%
	skipabove=8pt,
	linewidth=2pt,
	rightline=false,
	leftline=true,
	topline=false,
	bottomline=false,
	linecolor=ForestGreen,
	backgroundcolor=ForestGreen!5,
}
\declaretheoremstyle[
	headfont=\bfseries\sffamily\color{ForestGreen!70!black},
	bodyfont=\normalfont,
	spaceabove=2pt,
	spacebelow=1pt,
	mdframed={style=mdgreenbox},
	headpunct={ --- },
]{thmgreenbox}

%\mdfdefinestyle{mdblackbox}{%
%	skipabove=8pt,
%	linewidth=3pt,
%	rightline=false,
%	leftline=true,
%	topline=false,
%	bottomline=false,
%	linecolor=black,
%	backgroundcolor=RedViolet!5!gray!5,
%}
%\declaretheoremstyle[
%	headfont=\bfseries,
%	bodyfont=\normalfont\small,
%	spaceabove=0pt,
%	spacebelow=0pt,
%	mdframed={style=mdblackbox}
%]{thmblackbox}

\theoremstyle{theorem}
\declaretheorem[name=Remark,sibling=theorem,style=thmgreenbox]{remark}

\theoremstyle{definition}
\newtheorem{claim}[theorem]{Claim}
\newtheorem{definition}[theorem]{Definition}
\newtheorem{fact}[theorem]{Fact}

\newcommand{\vocab}[1]{\textbf{\color{blue} #1}}
]]
local preamble = [[
\documentclass[a4paper, 11pt]{article}

%% Language and font encodings
\usepackage[english]{babel}
\usepackage[utf8]{inputenc}
% \usepackage{fontspec}
% \setmainfont[
% BoldFont=calibrib.ttf,
% ItalicFont=calibrii.ttf,
% ]{Calibri.ttf}

%% Sets page size and margins
\usepackage[a4paper,top=2cm,bottom=2cm,left=2cm,right=2cm,marginparwidth=1.75cm]{geometry}

%% Useful packages
\usepackage{bm}
\usepackage{amsmath,amssymb,amsfonts}
\usepackage[hybrid]{markdown}
\usepackage{graphicx}
\usepackage{longtable}
\usepackage[dvipsnames,table,xcdraw]{xcolor}
\usepackage{hhline}
\usepackage[ruled,vlined]{algorithm2e}
\usepackage{soul}
\usepackage{listings}
\usepackage{pdfpages}
\usepackage{cancel}
\usepackage{afterpage}
\usepackage{todonotes}
\usepackage{xcolor}
\usepackage{tikz}
% \usepackage{tikzit}
% \input{tikzitstyles.tikzstyles}
\usepackage{fancyhdr}
\usepackage[colorlinks=true, allcolors=blue]{hyperref}
\usepackage{setspace}
\usepackage{subfiles}
% \usepackage[
% backend=biber,
% style=alphabetic,
% ]{biblatex}
% \addbibresource{ref.bib} %Imports bibliography file
\usepackage{amsthm}
\usepackage{xfrac}

\newcommand{\R}{\mathbb{R}}
\newcommand{\CC}{\mathbb{C}}
\newcommand{\N}{\mathbb{N}}
\newcommand{\Z}{\mathbb{Z}}
\newcommand{\Op}{\mathcal{O}}
\newcommand{\iprod}[1]{\left\langle {#1} \right\rangle}
\DeclareMathOperator*{\argmin}{argmin}
\DeclareMathOperator*{\argmax}{argmax}
\newcommand{\sspan}{\operatorname{span}}

\definecolor{codegreen}{rgb}{0,0.6,0}
\definecolor{codegray}{rgb}{0.5,0.5,0.5}
\definecolor{codepurple}{rgb}{0.58,0,0.82}
\definecolor{backcolour}{rgb}{0.95,0.95,0.92}
\lstdefinestyle{mystyle}{
	backgroundcolor=\color{backcolour},
	commentstyle=\color{codegreen},
	keywordstyle=\color{magenta},
	numberstyle=\tiny\color{codegray},
	stringstyle=\color{codepurple},
	basicstyle=\ttfamily\footnotesize\singlespacing,
	breakatwhitespace=false,
	breaklines=true,
	captionpos=b,
	keepspaces=true,
	numbers=left,
	numbersep=5pt,
	showspaces=false,
	showstringspaces=false,
	showtabs=false,
	tabsize=2
}
\lstset{style=mystyle}

\usepackage{parskip}
% \setlength{\parskip}{\baselineskip}%
% \setlength{\parindent}{0pt}%

\newcommand\setrow[1]{\gdef\rowmac{#1}#1\ignorespaces}
\newcommand\clearrow{\global\let\rowmac\relax}

\newcommand\Ccancel[2][black]{
    \let\OldcancelColor\CancelColor
    \renewcommand\CancelColor{\color{#1}}
    \cancel{#2}
    \renewcommand\CancelColor{\OldcancelColor}
}
\newcommand{\rcancel}[1]{ \Ccancel[red]{#1} }
\newcommand{\cleft}[2][.]{%
  \begingroup\colorlet{savedleftcolor}{.}%
  \color{#1}\left#2\color{savedleftcolor}%
}
\newcommand{\cright}[2][.]{ \color{#1}\right#2\endgroup }
\newcommand{\rleft}[1]{ \cleft[red]{#1} }
\newcommand{\rright}[1]{ \cright[red]{#1} }


%
%
% Document formatting ends here
%

]]
local docinfo = [[
%
% Document Info starts here
%
%

\title{${1:Homework}}
\author{${2:Anshuman Medhi}}
% \date{}

% Sections
% \renewcommand{\thesection}{\arabic{section}.}
% \renewcommand{\thesubsection}{\quad\alph{subsection}.}
% \renewcommand{\thesubsection}{\thesection\alph{subsection})}

% Header/footer
\pagestyle{fancy}
\fancyhf{}
\makeatletter
\let\headerauthor\@author
\let\headertitle\@title
\makeatother
\lhead{\headertitle}
\lfoot{\nouppercase\leftmark}
\rfoot{Page \thepage}

% \onehalfspacing
\doublespacing
\begin{document}

%\thispagestyle{empty}
\maketitle

%\newpage
%\begin{abstract}
%\end{abstract}

%\newpage
%\tableofcontents

%\listoffigures

$0

\end{document}
]]

local main = preamble .. notestheorems .. docinfo
local hw = preamble .. hwktheorems .. docinfo
local sub = [[\documentclass[${1:../main.tex}]{subfiles}

\begin{document}
\section{$2}
$0
\end{document}
]]
local essay = preamble .. notestheorems .. docinfo

return {
  tex = {
    ["table"] = [[
\begin{table}[${1:htpb}]
	\centering
	\caption{${2:caption}}
	\label{tab:${3:label}}
	\begin{tabular}{${5:c}}
	$0${5/((?<=.)c|l|r)|./(?1: & )/g}
	\end{tabular}
\end{table}
    ]],
    -- TODO: Change this to lua format
    ["figure"] = [[
\begin{figure}[${1:htpb}]
	\centering
	${2:\includegraphics[width=0.8\textwidth]{$3}}
	\caption{${4:$3}}
	\label{fig:${5:${3/\W+/-/g}}}
\end{figure}
    ]],
    ["codeinline"] = [[
\begin{lstlisting}[language=${1:Python}]
      $0
\end{lstlisting}
    ]],
    ["codefile"] = [[ \lstinputlisting[language=${1:Python}]{$0} ]],
    ["maintemplate"] = main,
    ["essaytemplate"] = essay,
    ["subtemplate"] = sub,
    ["hwktemplate"] = hw,
    --     ["subnotestemplate"]=[[
    -- \documentclass[../main/main.tex]{subfiles}
    --
    -- \begin{document}
    --
    -- \section{`d=$(date +%e); case $d in 1?) d=${d}th ;; *1) d=${d}st ;; *2) d=${d}nd ;; *3) d=${d}rd ;; *) d=${d}th ;; esac; date +"%B $d, %Y"`}
    -- \subsection{${1:Topic}}
    -- $0
    -- \end{document}
    --     ]]
  },
}
