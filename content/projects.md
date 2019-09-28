+++
type = "misc"
title = "Projects"
+++

# [CryptoKnight: Generating and Modelling Compiled Cryptographic Primitives](http://www.mdpi.com/2078-2489/9/9/231)

CryptoKnight is a tool I developed during my undergraduate at Abertay University. It is designed to aid in the analysis of crypto-ransomware; programs 
that lock down your computer by encrypting files and preventing access until a ransom has been paid. You might remember the attack on the NHS in 2018 
which used a particular instance known as WannaCry. My methodology (as previously introduced in [preprint](https://arxiv.org/abs/1709.08385)) leverages 
deep learning to process the application and evaluate the particular algorithms within it in a smarter and faster way. It was awarded the 
[Honorary Fellows Prize for Innovation](https://www.abertay.ac.uk/news/2017/prizewinners-honoured-for-stellar-achievements) by Abertay University in 2017 
and the code has since been [open-sourced](https://github.com/AbertayMachineLearningGroup/CryptoKnight) as of publication by MDPI.

# [Kali Linux Web Penetration Testing Cookbook](https://books.google.co.uk/books?id=iGRLDAAAQBAJ&pg=PP6&lpg=PP6&dq=Greg+Hill&source=bl&ots=pNp9rSoYN3&sig=RlthaecEN2cdvhPcESQsRvz3Y5c&hl=en&sa=X&ved=0ahUKEwikg8yknozWAhUhLMAKHUlJDHEQ6AEIOjAF#v=onepage&q=Greg%20Hill&f=false)

I was approached to review the 'Kali Linux Web Penetration Testing Cookbook' by Packt Publishing in 2015. After thoroughly testing all content and 
investigating improvements, I was acknowledged as a reviewer when it was published in early 2016.

# [The Modern Relationship Between Cryptography And Machine Learning](/docs/irr.pdf)

This literature review was composed as part of a module at the <a href='http://www.inf.ed.ac.uk/teaching/courses/irr/'>University of Edinburgh</a>. 
Based on an older study by <a href='http://people.csail.mit.edu/rivest/pubs/Riv91.pdf'>Rivest</a>, the aim was to survey contemporary research areas 
linked to the intersection between these two fundamental areas of study.

# [Image Forgery Detection](/docs/mlp.pdf)

Despite efforts to detect fictitious content, it is more prevalent than ever. Deep neural networks give practitioners the ability to realistically 
alter the content in digital media with veritable ease, but can these systems be used to combat illicit material? As part of a group project for 
[Machine Learning Practical (MLP)](https://www.inf.ed.ac.uk/teaching/courses/mlp/), we implemented a proof-of-concept classification tool to discriminate 
between real and fake images.

# [Intrusion Detection System (IDS) Evasion](/docs/idsevasion.pdf)

As part of a third year module at Abertay University I evaluated common packages that aim to combat network incursion and detect advanced persistent threats. 
By comparing their ability to prevent several evasion techniques, the results concluded that these setups occasionally faltered due to outdated rulesets.

# [Cross-Site Scripting (XSS) Fuzzing](/docs/xssfuzzing.pdf)

The attack surface of a typical web application is often quite large, hence it can prove challenging for a security professional to locate and exploit certain 
vulnerabilities. I studied five different automated XSS tools to illustrate advanced tactics for web exploitation that simplified vulnerability location. The 
latter stage of the report proposed countermeasures based on the [OWASP](https://www.owasp.org/) guidelines.

# [Denial of Service (DoS) Attack Methodologies](/docs/ddos.pdf)

This paper outlined volume based, protocol and application layer attacks utilised by infamous hacktivists. The aim of the project was to demonstrate the ease of 
scripting and aid in the design of more resilient systems. It concluded that targeted HTTP flooding was by far the most effective technique. The project was presented 
at SecuriTay 5 and [BerlinSides](https://berlinsides.org/?page_id=1911) in 2016.

# [Exploit Development](/docs/exploit.pdf)

Each student was randomly assigned a vulnerable media application to track inherent security flaws and construct custom payloads. It was shown that GSPlayer (Windows XP)
suffered from a buffer overflow vulnerability that was exploitable despite enabling Data Execution Prevention (DEP). The project utilised WinDbg, OllyDbg and Immunity 
Debugger to disassemble and analyse the subject binary.
