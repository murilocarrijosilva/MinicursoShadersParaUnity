# MinicursoShadersParaUnity
Repositório com os arquivos utilizados no minicurso "Desenvolvendo Shaders para Unity", aplicado pelo Fellowship of The Game

## 0. Sumário
  - [1. Introdução](#1-Introdução)
    - [O que são shaders?](#O-que-são-shaders)
    - [Renderização e a pipeline gráfica](#Renderização-e-a-pipeline-gráfica)
  - [2. Shaders na Unity](#2-Shaders-na-Unity)
    - [Como a Unity utiliza shaders](#Como-a-Unity-utiliza-shaders)
    - [Introdução ao ShaderLab](#Introdução-ao-ShaderLab)
    - [Cg/HLSL](#cghlsl)
  - [3. Nosso primeiro Shader](#3-Nosso-primeiro-shader)
    - [Escrevendo Shaders](#escrevendo-shaders)
    - [Tipos de dados e *semantics*](#tipos-de-dados-e-semantics)
    - [Mostrando uma cor](#Mostrando-uma-cor)
    - [Transformações de espaços](#Transformações-de-espaços)
    - [Propriedades ShaderLab](#Propriedades-ShaderLab)
  - [4. Texturas](#4-texturas)
    - [Coordenadas UV](#coordenadas-uv)
    - [Aplicando texturas](#aplicando-texturas)
    - [Combinando texturas](#combinando-texturas)
    - [Combinando com máscaras](#combinando-com-mascaras)

## 1. Introdução

### O que são shaders?
  Shaders são, basicamente, programas executados pela placa de vídeo (GPU), e cujo papel é descrever como renderizar uma imagem. O termo vem de "sombreamento", visto que uma das aplicações mais comuns de shaders é em modelos de iluminação.

  No contexto de desenvolvimento de jogos, shaders são poderosas ferramentas artísticas que podem ser aplicadas em quaisquer aspectos visuais de seu jogo. Eles são utilizados para desenvolver gráficos estilizados, efeitos especiais, efeitos de processamento, geometria dinâmica (e.g. neve e grama), elementos da GUI, entre outras coisas. Basicamente, se é algo visual, conseguimos aplicar shaders.
  
  Para entender melhor o papel desses programas, vamos passar rapidamente pelo processo de renderização.
  
### Renderização e a pipeline gráfica
  'Renderização' é o processo pelo qual obtemos uma imagem a partir de informação. Essa informação pode ser a descrição de um único objeto ou de uma cena complexa, com diversos objetos, luzes, texturas e etc, sendo que é papel da GPU (e dos programas que executam nela) transformar isso tudo em uma imagem 2D para ser apresentada na tela.
  O seguinte diagrama (retirado do [The Cg Tutorial](http://developer.download.nvidia.com/CgTutorial/cg_tutorial_chapter01.html)) apresenta de uma maneira bastante simplificada os passos executados.
  
  ![imagem](https://developer.download.nvidia.com/CgTutorial/elementLinks/fig1_3.jpg)
  
  Basicamente:
  - Informações sobre os vértices dos objetos a serem renderizados são passados para um programa que, através de algumas transformações matemáticas, decide a posição na tela que esses vértices irão ocupar. Essas informações incluem posição, vetor normal, cor, coordenadas de textura, etc.
  - A GPU constrói as formas descritas por esses vértices (normalmente triângulos) e decide quais pixels na tela elas ocupam. Nem todo pixel ocupado será apresentado na imagem final. Esses "pixels em potencial" são chamados de *fragments*.
  - Para cada fragment é executado um programa que, através das informações dos vértices transformados, executa mais uma série de transformações matemáticas para decidir uma cor final para aquele pixel. Texturas, por exemplo, são aplicadas nessa etapa. É possível definir também um valor para profundidade (basicamente a distância entre aquele ponto no espaço e o observador).
  - Por fim, a GPU realiza uma série de operações (por exemplo, cálculos de transparência que precisam combinar pixels) para decidir a cor final de cada pixel, e então apresenta a imagem na tela.
  
  Os primeiros shaders que vamos escrever tem o papel de influenciar nas etapas da pipeline. Mais especificamente em dois passos: a transformação dos vértices e coloração dos fragments.
  
  #### Para mais informações:
  - [Artigo na Wikipédia sobre renderização](https://en.wikipedia.org/wiki/Rendering_(computer_graphics))
  - [Artigo na Wikipédia sobre a pipeline gráfica](https://en.wikipedia.org/wiki/Graphics_pipeline)
  - [Capítulo 1 do The Cg Tutorial](http://developer.download.nvidia.com/CgTutorial/cg_tutorial_chapter01.html)
  - [Série de vídeos no canal Computerphile](https://www.youtube.com/watch?v=KdyvizaygyY&list=PLzH6n4zXuckrPkEUK5iMQrQyvj9Z6WCrm)

## 2. Shaders na Unity

### Como a Unity utiliza shaders
  Alguns dos conceitos básicos essenciais no processo de renderização da Unity são *Meshes*, *Materiais* e *Shaders*. Meshes descrevem a geometria de um objeto, enquanto materiais e shaders descrevem como renderizá-lo. *Materiais* funcionam como um tipo de "instância" de shader, de modo que neles conseguimos definir as propriedades para serem passadas para o programa. Os materiais podem então ser aplicados em objetos que possuem algum componente do tipo Renderer (e.g. Mesh Renderer, Sprite Renderer, Trail Renderer) ou até em um Sistema de Partículas, para que esses sejam renderizados a partir do material (e consequentemente do shader).
  
  Para criar um material basta selecionar a opção *Material* no menu *Create* na aba de projeto.
  
  ![Criando um material na Unity](https://i.imgur.com/vqTFk1u.png)
  
  Com o material selecionado, conseguimos alterar suas propriedades no inspetor. Perceba, no topo, a opção Shader: ali conseguimos selecionar o shader que esse material utiliza. A Unity oferece alguns shaders padrão para objetos, sprites, etc.
  
  ![Inspetor do material](https://i.imgur.com/h9fJ5Nj.png)

### Introdução ao ShaderLab
  Hora de começar a escrever nossos próprios shaders. A Unity utiliza uma linguagem declarativa chamada [ShaderLab](https://docs.unity3d.com/Manual/SL-Shader.html) que encapsulam programas shader, descrevendo como apresentá-los no inspetor e como integrá-los ao restante da pipeline de renderização do Unity (mais sobre isso depois).
  Na aba projeto, no menu *Create > Shader* temos como opção alguns templates. Selecione o *Unlit Shader*.
  
  ![Criando um novo shader com o template "Unlit Shader"](https://i.imgur.com/iUh94n0.png)
  
  Abrindo o arquivo teremos mais ou menos isso
  ```c
  Shader "Unlit/NewUnlitShader" {
    Properties {
      // Propriedades
    }
    
    SubShader {
      Tags { /* Tags */ }
      Pass {
        CGPROGRAM
        // Código do shader
        ENDCG
      }
    }
  }
  
  ```
  Essa é a sintaxe do ShaderLab.
  
  O bloco `Shader "NomeDoShader" { ... }` define um novo programa Shader. O nome indicado aparecerá como uma opção para ser selecionada em materiais. Vamos mudar o nome no shader que acabamos de criar para `"Minicurso/PrimeiroShader"`. Selecionando ele e aplicando em algum objeto na cena, veja que o objeto é renderizado apenas com uma cor.
  
  ![Selecionando o menu Minicurso](https://i.imgur.com/lCMFK0t.png)
  ![Uma esfera renderizada com o material utilizando o novo shader criado](https://i.imgur.com/KCCyfN1.png)
  
### Cg/HLSL
  O código do shader em si é escrito em Cg/HLSL e no arquivo está dentro do bloco
  ```c
  CGPROGRAM
  // Código do shader
  ENDCG
  ```
  Cg (*C for graphics*) e HLSL (*High-Level Shading Language*) são dois nomes para a mesma linguagem, com a distinção de que a primeira se trata da implementação da NVIDIA, e a segunda da Microsoft. A linguagem é fruto da colaboração entre as duas empresas.
  
  A Unity originalmente utilizava Cg para shaders, visível em palavras-chave e extensões utilizadas (`CGPROGRAM`, `.cginc`). Entretanto, a linguagem não está mais em desenvolvimento e, portanto, todo código atualmente de ser um programa HLSL válido. Diferentes sintaxes para as mesmas finalidades existem com pequenas variações de comportamento, em maior parte para o suporte de diferentes versões do Direct3D. Para mais detalhes, [consultar a documentação](https://docs.unity3d.com/Manual/SL-ShadingLanguage.html).
  
  Aqui vamos evitar ao máximo problemas com essa distinção entre as linguagens utilizando macros e funções oferecidas pela Unity.
  
  Para consulta sobre a linguagem, os manuais para Cg também são válidos. A maior parte da sintaxe é equivalente, e os guias para Cg são bem mais didáticos (em minha humilde opinião). O livro [The Cg Tutorial](http://developer.download.nvidia.com/CgTutorial/cg_tutorial_chapter01.html) aborda além da linguagem tópicos como sistemas de coordenadas e matrizes de transformação (mais sobre isso daqui a pouco), técnicas para iluminação e outros tópicos avançados. Para consulta sobre elementos da linguagem (semânticas, funções disponíveis, etc) os guias da Microsoft são recomendados por serem mais atualizados (considerando variações de edições mais recentes do Direct3D).
  
  #### Para mais informações:
  - [The Cg Tutorial](http://developer.download.nvidia.com/CgTutorial/cg_tutorial_chapter01.html)
  - [Cg Language Reference](https://developer.download.nvidia.com/cg/Cg_language.html)
  - [Cg Standard Library Documentation](https://developer.download.nvidia.com/cg/index_stdlib.html)
  - [Programming guide for HLSL](https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-pguide)
  - [Reference for HLSL](https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-reference)

## 3. Nosso primeiro Shader

### Escrevendo Shaders
  Vamos então programar nosso primeiro shader. No arquivo que acabamos de criar, apague tudo exceto pela tag externa. Vamos ficar apenas com
  ```c
  Shader "Minicurso/PrimeiroShader" {
  
  }
  ```
  A partir daqui, novos elementos do ShaderLab serão introduzidos conforme necessidade.
  
  Dentro do Shader, precisamos definir um `SubShader`. Cada Shader na Unity é composto por uma lista de um ou mais SubShaders, de modo que, quando algo precisa ser renderizado, será utilizado o primeiro SubShader compatível com o hardware atual. Em um programa mais complexo, poderíamos ter uma série de SubShaders para dar suporte a uma gama de dispositivos, levando em consideração limitações em, por exemplo, smartphones. Aqui, vamos utilizar apenas um. Temos agora então
  ```c
  Shader "Minicurso/PrimeiroShader" {
    SubShader {
    
    }
  }
  ```
  Cada SubShader, por sua vez, define uma lista de `Pass`es. Um objeto é renderizado uma vez para cada Pass. Múltiplos Passes são utilizados, por exemplo, para iluminação, quando várias luzes devem afetar o objeto. Novamente, vamos utilizar apenas um. Temos então
  ```c
  Shader "Minicurso/PrimeiroShader" {
    SubShader {
      Pass {
      
      }
    }
  }
  ```
  Agora, finalmente, podemos começar a escrever o shader em si. Antes disso, poderíamos definir uma série de opções no Pass, mas veremos isso mais pra frente. Por enquanto, vamos apenas declarar um programa Cg/HLSL com as tags
  
  ```c
  Shader "Minicurso/PrimeiroShader" {
    SubShader {
      Pass {
        CGPROGRAM
        
        ENDCG
      }
    }
  }
  ```
  (A partir daqui, subentendesse que os trechos de código estão dentro do bloco  `CGPROGRAM` `ENDCG`, exceto onde se explicita o restante da sintaxe do ShaderLab).
  
  A partir do que vimos sobre renderização, sabemos que teremos dois programas com funções distintas: um para definir a posição dos vértices na tela e outro para definir a cor dos fragmentos. Além disso, precisamos receber e enviar informação para outras etapas na pipeline.
  
  Começamos indicando para o compilador o nome dos programas de vertex e fragment para que ele consiga encontrá-los. Fazemos isso através de diretivas `#pragma`, da seguinte forma.
```c
#pragma vertex VertexProgram
#pragma fragment FragmentProgram

```
"VertexProgram" e "FragmentProgram" são os valores que escolhemos pro nome das funções. Os valores não precisam ser necessariamente esses.

Se formos tentar compilar o programa agora, obteremos um erro, denotado pelos avisos no console e pelos objetos renderizados com a cor magenta. Isso porque não declaramos os programas. Vamos fazer isso em seguida.

```c
#pragma vertex VertexProgram
#pragma fragment FragmentProgram

void VertexProgram() {
}

void FragmentProgram() {
}
```
Os programas shader em si são declarados como funções em C.
`void` é o tipo de retorno. A linguagem Cg conta com diversos tipos numéricos e vetoriais, veremos eles daqui a pouco. "void" significa apenas que nenhum valor é retornado.

Em seguida temos o nome da função seguido de parênteses. O nome deve ser idêntico aos valores declarados nas diretivas acima, do contrário os programas não serão reconhecidos. Os parênteses indicam os parâmetros. Aqui, eles serão os valores que pegaremos dos passos anteriores da pipeline.

Caso o programa compile (pode ainda não compilar dependendo da API gráfica utilizada em seu computador), agora os objetos renderizados com ele estão invisíveis. Isso porque ainda não fizemos nenhuma das operações que vimos, definir a posição e uma cor. Antes disso vamos ver como lidamos com dados.

### Tipos de dados e *semantics*
Os tipos disponíveis em HLSL são semelhantes aos do C (e consequentemente muitas outras linguagens), exceto por alguns específicos para lidar vetores, matrizes e texturas. Assim, temos valores numéricos como `int` e `float` que representam um único valor. Além disso, conseguimos declarar vetores conectando junto um número, de modo que `float3` é um vetor com três componentes. De maneira semelhante, `float3x3` representa uma matriz com 3 linhas e colunas.

Outro aspecto importante da linguagem é que precisamos conectar as coisas com o restante da pipeline. Os valores que entram e saem da função precisam ser identificados para que sejam utilizados corretamente. Fazemos isso através do uso de *semantics*, que conectamos junto aos valores que entram e saem de funções para declarar seu uso intencionado. Veremos seu uso logo em seguida.

#### Para mais informações:
  - [Unity Shader Semantics](https://docs.unity3d.com/Manual/SL-ShaderSemantics.html)
  - [HLSL Data Types](https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-data-types)
  - [HLSL Semantics](https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-semantics)
### Mostrando uma cor
Vamos então fazer nosso shader exibir alguma coisa. Sabemos que nosso `VertexProgram` deve definir uma posição e que o `FragmentProgram` deve definir uma cor. Ambas essas informações são representadas como vetores com 4 componentes (a posição tem os valores `x, y, z` representando a posição no espaço e um último valor especial `w`. A cor tem os canais `r, g, b, a`). Vamos então mudar o tipo de retorno das funções para `float4` e adicionar uma linha `return 0;`. Apesar de o valor de retorno ter 4 componentes (então estamos tecnicamente retornando `float4(0, 0, 0, 0)`) a linguagem facilita esse tipo de conversão implícita.

Temos então
```c
#pragma vertex VertexProgram
#pragma fragment FragmentProgram

float4 VertexProgram() {
  return 0;
}

float4 FragmentProgram() {
  return 0;
}
```
Salvando o programa vamos obter alguns erros. Como não informamos as *semantics* de saída o programa não sabe o que deve fazer com os valores que estamos retornando. Vamos adicioná-las agora. Teremos
```c
#pragma vertex VertexProgram
#pragma fragment FragmentProgram

float4 VertexProgram() : SV_POSITION {
  return 0;
}

float4 FragmentProgram() : SV_TARGET {
  return 0;
}
```
Agora que informamos o que os valores representam (*SV* significa *System Value*, a position é a posição final do vértice e target o alvo de renderização, aqui no caso o *frame buffer* que contém informação sobre a imagem que estamos renderizando) o nosso programa mostra... nada! Mas pelo menos sem erros. 

Vamos agora posicionar nossos vértices. Precisamos pegar a informação de posição no programa de vértice. Se informarmos o valor como parâmetro ele será passado para o programa pela pipelina. Vamos adicionar então
```c
#pragma vertex VertexProgram
#pragma fragment FragmentProgram

float4 VertexProgram(float4 vertexPosition : POSITION) : SV_POSITION {
  return 0;
}

float4 FragmentProgram() : SV_TARGET {
  return 0;
}
```
E agora temos acesso ao valor da posição de cada vértice. Para conseguirmos posicionar nossos vértices corretamente, precisamos entender o que esse valor significa. Vamos simplesmente retornar o valor sem modificá-lo para ver o que acontece quando renderizamos uma esfera com ele.

```c
#pragma vertex VertexProgram
#pragma fragment FragmentProgram

float4 VertexProgram(float4 vertexPosition : POSITION) : SV_POSITION {
  return vertexPosition;
}

float4 FragmentProgram() : SV_TARGET {
  return 0;
}
```

![Renderizando uma esfera com as posições dos vértices](https://i.imgur.com/sYaq8Q6.png)

A esfera deixou de ser uma esfera. Além disso, perceba que quando movimentamos a câmera ela permanece estática.

Isso ocorre pois estamos lidando com diferentes referenciais. O valor da posição do vértice é em relação ao próprio objeto, e estamos interpretando ele como uma coordenada na tela. Para corrigir isso, vamos utilizar uma função pré-definida da Unity.

Para isso, vamos incluir um dos arquivos auxiliares que a Unity oferece, o `UnityCG.inc`. Fazemos isso com a diretiva `#include`, que basicamente pega o conteúdo do arquivo indicado e coloca onde declaramos. [Você pode ver mais sobre os arquivos include que a Unity oferece aqui](https://docs.unity3d.com/Manual/SL-BuiltinIncludes.html).

Além disso, vamos trocar o valor de retorno do `FragmentProgram` para `float4(0, 1, 0, 1)`, que deverá aparecer como verde. Temos então

```c
#pragma vertex VertexProgram
#pragma fragment FragmentProgram

#include "UnityCG.cginc"

float4 VertexProgram(float4 vertexPosition : POSITION) : SV_POSITION {
  return UnityObjectToClipPos(vertexPosition);
}

float4 FragmentProgram() : SV_TARGET {
  return float4(0, 1, 0, 1);
}
```

![Renderizando a esfera corretamente e com a cor verde](https://i.imgur.com/07N6QWH.png)

Tadam! Uma esfera verde posicionada corretamente no espaço. Você também pode mudar o valor de retorno do `FragmentProgram` para mostrar outras cores. Os canais r, g, b tem insendidade entre 0 e 1. O canal alfa, apesar de normalmente representar transparência, não faz nada em nosso programa (não se preocupe, vamos ver transparência no futuro).

### Transformando vértices
Utilizamos uma função dada pela Unity, `UnityObjectToClipPos(float3 position)`, para posicionar corretamente os vértices. Mas como ela funciona?

Como já comentado brevemente, dependendo de onde estamos na pipeline gráfica, estamos lidando com diferentes sistemas de coordenadas. Como a imagem final renderizada precisa ser apresentada em uma tela, precisamos de uma forma de transformar um objeto 3D, posicionado em algum lugar de uma cena, em uma imagem 2D. Isso é feito através do uso de matrizes.

Os sistemas de coordenadas mais importantes para nós são os do *Object Space*, *World Space* e *Clip Space*. O valor da `vertexPosition` quando entramos no `VertexProgram` está no *Object Space* (ou *Model Space*). Esse valor vem da própria *Mesh*, e não tem qualquer relação com outros objetos na cena.

Quando posicionamos um objeto na cena, ele tem uma posição no "mundo". Conseguimos, por exemplo, posicionar dois objetos que utilizam a mesmas Mesh, mas em posições diferentes. Nesse caso, a posição dos vértices quando entramos no shader serão iguais, mas o Unity nos oferece formas de transformar esse valor em uma posição no mundo.

Por fim, temos que "achatar" todos os objetos em um plano 2D para apresentar a imagem. Vimos que esse é um dos papéis do Vertex Shader, que deve calcular a posição na tela (o *clip space* e a posição na tela são coisas diferentes, mas para nossa finalidade não é relevante entender os detalhes de cada um).

As conversões entre esses espaços são feitas através da multiplicação de matrizes, de modo que essas matrizes armazenam as transformações necessárias para fazer a conversão entre o *Object Space* e o o *World Space*, e do *World Space* para o *Clip Space* (nessa ordem). Para isso então temos três matrizes: a *Model Matrix*, a *View Matrix* e a *Projection Matrix*. Juntas, elas formam a matriz MVP.

O Unity nos oferece algumas funções e macros para contornar toda a parte matemática, então o essencial é apenas entender que para converter entre os diferentes espaços precisamos multiplicar coisas.

Assim, a operação `UnityObjectToClipPos(vertexPosition)` é equivalente a `mul(UNITY_MATRIX_MVP, vertexPosition)` (inclusive se escrevermos a segunda forma ela será automaticamente substituída pela primeira). Além dessa função, também temos acesso às matrizes de transformação. Outra operação que devemos utilizar é converter do object space para o world space, e fazemos isso multiplicando pela variável `unity_ObjectToWorld` (a *model matrix* atual).

#### Para mais informações
  - [Built-in Shader Variables](https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html)
  - [Capítulo 4 do The Cg Tutorial](http://developer.download.nvidia.com/CgTutorial/cg_tutorial_chapter04.html)
  - [Catlike Coding Unity Rendering](https://catlikecoding.com/unity/tutorials/rendering/part-1/)

### Propriedades ShaderLab
Vamos voltar rapidamente ao ShaderLab para explorar o conceito de propriedades. No nosso programa atual, se quisermos mudar a cor do objeto sendo exibido precisamos alterar o valor no código. Ainda, se quisermos ter outro objeto utilizando o mesmo Shader mas com uma cor diferente, precisariamos escrever outro programa quase idêntico.

Para evitar isso, temos a opção de criar *propriedades* para nosso shader que conseguimos então definir no inspetor do material. Para isso, acima do bloco `SubShader`, vamos incluir um bloco `Properties`

```c
Shader "Minicurso/PrimeiroShader" {
  Properties {
  }
  
  SubShader {
    ...
  }
}
```

Entre os tipos de propriedades que conseguimos definir temos valores numéricos, cores e imagens. Para definir uma propriedade, indicamos um nome, um identificador (para o inspetor), um tipo e o valor padrão. Para criar uma cor, então, temos

```c
Shader "Minicurso/PrimeiroShader" {
  Properties {
    _Color("Cor do objeto", Color) = (0, 1, 0, 1)
  }
  
  SubShader {
    ...
  }
}
```
e agora, se formos no inspetor do material, temos

![Inspetor do material com a propriedade de cor](https://i.imgur.com/Gnd5AZ0.png)

para recuperar o valor em nosso programa shader, precisamos declarar uma variável com o mesmo nome dado e um tipo equivalente. Assim, teremos em nosso programa
```c
Shader "Minicurso/PrimeiroShader" {
  Properties {
    _Color("Cor do objeto", Color) = (0, 1, 0, 1)
  }
  
  SubShader {
    #pragma vertex VertexProgram
    #pragma fragment FragmentProgram

    #include "UnityCG.cginc"
    
    float4 _Color;

    float4 VertexProgram(float4 vertexPosition : POSITION) : SV_POSITION {
      return UnityObjectToClipPos(vertexPosition);
    }

    float4 FragmentProgram() : SV_TARGET {
      return _Color;
    }
  }
}
```
e pronto, conseguimos escolher a cor pelo inspetor! Além disso, conseguimos também criar mais materiais que utilizam o mesmo shader mas que têm cores diferentes.

![Duas esferas com materiais diferentes utilizando o mesmo shader](https://i.imgur.com/OQw2JiO.png)

Além de cores, temos outros tipos de propriedade.
```
_Int("Eu sou um número inteiro", Int) = 12
_Float("Eu sou um número de ponto flutuante", Float) = 12.34
_Range("Eu sou um slider entre dois números", Range(0, 1)) = 0.5

_Cor("Eu sou uma cor", Color) = (1, 0.85, 0.34, 1)
_Vetor("Eu sou um vetor", Vector) = (1, 2, 3, 4)

_Texture1("Eu sou uma textura 2D", 2D) = "white" {}     // Valores padrão para texturas são apenas
_Texture2("Eu sou uma textura Cube", Cube) = "gray" {}  // "white", "gray" e "black", que correspondem
_Texture3("Eu sou uma textura 3D", 3D) = "black" {}     // às cores (1, 1, 1, 1), (0.5, 0.5, 0.5, 0.5) e (0, 0, 0, 0).
```
![Todas as propriedades acima no inspetor do material](https://i.imgur.com/dhBZrAj.png)

Para mais informações sobre propriedades, [consultar a documentação](https://docs.unity3d.com/Manual/SL-Properties.html).
## 4. Texturas

### Coordenadas UV
Além da posição, temos diversas outras informações que conseguimos recuperar dos vértices. Aqui, veremos como aplicar texturas no objeto, e, para isso, utilizaremos as coordenadas UV.

Coordenadas UV são uma forma de mapear uma imagem 2D em um objeto 3D. Esse mapeamento é definido pelo artista 3D, sendo que o processo é chamado de *UV unwrapping*, e, como o nome indica, é análogo a "desdobrar" o objeto, como um origami.

A seguinte imagem exemplifica como isso funciona. Para cada vértice se atribui uma coordenada entre (0, 0) e (1, 1), sendo essa sua coordenada UV. Conseguimos então, a partir disso, pegar uma imagem com coordenadas normalizadas (o canto inferior esquerdo é a posição (0, 0) e o superior direito a posição (1, 1)) e relacionar cada ponto no objeto com um ponto na imagem.

![UV Unwrap de um cubo no Blender](https://i.imgur.com/srtlbaJ.png)

Vamos então criar um novo programa Shader. Antes de incluir as coordenadas UV, vamos fazer algumas pequenas alterações no VertexProgram para facilitar passar informação entre o VertexProgram e o FragmentProgram. Teremos

```c
Shader "Minicurso/Textura" {
  SubShader {
    Pass {
      CGPROGRAM
      
      #pragma vertex VertexProgram
      #pragma fragment FragmentProgram
      
      #include "UnityCG.cginc"
      
      struct VertexInput {
      	float4 position : POSITION;
      };
      
      struct VertexOutput {
      	float4 position : SV_POSITION;
      };
      
      VertexOutput VertexProgram(VertexInput i) {
        VertexOutput o;
	o.position = UnityObjectToClipPos(i.position);
	return o;
      }
      
      float4 FragmentProgram(VertexOutput v) {
      	return float4(1, 1, 1, 1);
      }
      
      ENDCG
    }
  }
}
```
Com isso conseguimos adicionar mais facilmente novas informações. As estruturas definidas funcionam como um agrupamento de dados e nos permitem reunir todos os parâmetros e suas semânticas em um único lugar.

Vamos agora então recuperar as coordenadas UV. Para isso vamos incluir no `VertexInput`
```c  
struct VertexInput {
  float4 position : POSITION;
  float2 uv : TEXCOORD0;
};
```
e como queremos que esse valor esteja disponível para nós no `FragmentProgram`, vamos adicionar também no `VertexOutput`
```c  
struct VertexOutput {
  float4 position : SV_POSITION;
  float2 uv : TEXCOORD0;
};
```
Note que os nomes não precisam ser iguais nas duas structs. Ainda, a *semantic* `: TEXCOORD0` tem um significado diferente no `VertexOutput`, mas veremos isso daqui a pouco.

Agora temos então acesso ao valor da coordenada UV no `VertexProgram`. Vamos torná-la acessível também no `FragmentProgram`. Para isso precisamos inicializar seu valor no `VertexProgram`, de modo que teremos
```c
VertexOutput VertexProgram(VertexInput i) {
  VertexOutput o;
  o.position = UnityObjectToClipPos(i.position);
  o.uv = i.uv; // simplesmente copiando o valor para o VertexOutput
  return o;
}
```
e agora conseguimos recuperar o valor através do `VertexOutput` que temos como parâmetro do `FragmentProgram`. Vamos então tentar interpretar o valor da UV como uma cor para ver se está tudo funcionando. Modificando o `FragmentProgram` teremos
```c
float4 FragmentProgram(VertexOutput v) : SV_TARGET {
  return float4(v.uv.xy, 0, 1);
}
```
Repare algumas das características da linguagem para acessarmos os valores e criarmos novos tipos. Para acessar as componentes de um vetor, indicamos qualquer sequência de valores `x, y, z, w` (dependendo do tamanho do vetor) que o valor será também um vetor. No programa estamos criando um novo `float4` preenchendo os dois primeiros componentes sendo, respectivamente, os valores do componente x e do componente y da UV.
De maneira semelhante, poderíamos declarar `v.uv.yx`, de modo que teríamos o mesmo resultado porém invertido. Ainda, podemos utilizar `v.uv.xx` ou `v.uv.yy`.
Salvando o arquivo, teremos na cena

![Exibindo as UVs de um cubo](https://i.imgur.com/7NVxaQN.png)

Estamos interpretando o componente x como a cor vermelha e o componente y como a verde. Temos então que cada face é mapeada do ponto (0, 0) até o (1, 1), pois temos um canto preto (cor (0, 0, 0, 1)) e um amarelo (cor (1, 1, 0, 1)). Isso é diferente por exemplo do cubo do blender que vimos logo acima. Por curiosidade, se exportássemos o cubo com a UV como está exibida na imagem acima teríamos

![Cubo com o UV Unwrapp padrão do Blender](https://i.imgur.com/g2JC7Ju.png)

### Aplicando texturas
Agora que temos acesso às coordenadas UV, temos como aplicar texturas.

Texturas são um tipo especial de dado que você provavelmente estará utilizando bastante ao desenvolver Shaders. Num primeiro momento, seu comportamento é bastante semelhante com um vetor (ou, mais especificamente, uma matriz), com cada pixel na imagem representando uma cor. Entretanto, as texturas tem a propriedade especial de poderem ser escalonadas conforme necessário, sendo que a GPU redimensiona a imagem dependendo do contexto. Isso ocorre constantemente, visto que o mero ato de afastar a câmera do objeto muda o tamanho aparente da imagem.

Para passar texturas para nosso programa Shader vamos declarar uma propriedade. Seguindo a sintaxe que vimos anteriormente adicionaremos, no topo de nosso Shader
```c
Properties {
  _MainTex("Main texture", 2D) = "white" {}
}
```
o nome "_MainTex" é especial para a Unity, representando a textura principal para o programa. Em alguns contextos esse valor é atribuido automaticamente, como veremos em *Image Effects*.

Agora precisamos acessar o valor no shader. O tipo com o qual declaramos texturas são os `sampler`s. Mais especificamente, utilizaremos um `sampler2D`. Assim, teremos até agora
```c
#pragma vertex VertexProgram
#pragma fragment FragmentProgram

#include "UnityCG.cginc"

struct VertexInput {
  float4 position : POSITION;
  float2 uv : TEXCOORD0;
};

struct VertexOutput {
  float4 position : SV_POSITION;
  float2 uv : TEXCOORD0;
};

sampler2D _MainTex;

VertexOutput VertexProgram(VertexInput i) {
  VertexOutput o;
  o.position = UnityObjectToClipPos(i.position);
  o.uv = i.uv;
  return o;
}

float4 FragmentProgram(VertexOutput v) : SV_TARGET {
  return float4(v.uv, 0, 1);
}
```
Vamos agora colocar a textura no objeto. Para acessar o valor da textura em determinada coordenada, temos a função HLSL `tex2D(sampler, coord)` que nos retorna o valor da cor na posição indicada. Vamos então modificar nosso `FragmentProgram`
```c
float4 FragmentProgram(VertexOutput v) : SV_TARGET {
  float4 texColor = tex2D(_MainTex, v.uv);
  return texColor;
}
```
Agora, se formos no inspetor do material e selecionarmos alguma textura

![Cubo com uma textura aplicada](https://i.imgur.com/aWBTC7f.png)

Tadam! Temos um cubo texturizado.

Algumas considerações antes de irmos para o próximo tópico. Você deve ter percebido que além da textura temos outros valores disponíveis para preencher no inspetor

![Configurações de Tiling e Offset no inspetor](https://i.imgur.com/VAVy8XM.png)

Modificando esses valores nada acontece com nosso cubo.

Para cada textura que declaramos, a Unity nos oferece junto algumas informações adicionais sobre ela. Conseguimos acessá-las através de parâmetros especiais em nosso programa. São eles
```c
  sampler2D _MainTex;
  float4 _MainTex_ST;
  float4 _MainTex_TexelSize;
  //tem também o float4 _MainTex_HDR, que é utilizado apenas caso a textura contenha informação sobre cor HDR. Não vamos utilizar ele aqui.
```
- [TextureName]`_ST`
Esse vetor armazena as informações de Tiling e Offset da textura (os valores que aparecem no inspetor logo acima), de modo que os componentes `x, y` contém os valores do tiling no eixo `x` e `y`, respectivamente, e os componentes `z, w` contém os valores de offset no eixo `x` e `y` respectivamente.

A Unity nos oferece no `"UnityCG.cginc` um macro para calcular o valor da UV levando em conta esses valores. Para o utilizarmos precisamos primeiro ter os dois parâmetros declarados (o `sampler2D` e o `float4` do sufixo `_ST`). Podemos então modificar nosso `VertexProgram` para

```c
VertexOutput VertexProgram(VertexInput i) {
  VertexOutput o;
  o.position = UnityObjectToClipPos(i.position);
  o.uv = TRANSFORM_TEX(v.uv, _MainTex);
  return o;
}
```

Salvando o programa, veja que agora modificando os valores modificamos também como a textura está sendo exibida.
- [TextureName]`_TexelSize`
Esse vetor armazena informação sobre o tamanho da textura, sendo que os componentes `x, y` armazenam, respectivamente, os valores inversos da largura e da altura (1/largura e 1/altura), e os componentes `z, w` armazenam os valores da largura e da altura.

Isso é útil pois conseguimos navegar entre os pixels. Conseguimos, por exemplo, verificarmos os valores dos pixels adjacentes à posição atual para adicionar uma borda em determinadas cores. 

Para mais informações sobre essas propriedades especiais, [veja a documentação.](https://docs.unity3d.com/Manual/SL-PropertiesInPrograms.html)

### Combinando texturas
Outra operação muito comum que vamos realizar é a combinação de texturas, seja para mesclar os valores ou para marcarar determinadas regiões. Vamos começar então declarando outra textura em nosso programa. Teremos então

```c
Shader "Minicurso/Texturas" {

  Properties{
    _MainTex("Main texture", 2D) = "white" {}
    _OutraTex("Outra textura", 2D) = "white" {}
  }

  SubShader{

    Pass {

      CGPROGRAM
      #pragma vertex VertexProgram
      #pragma fragment FragmentProgram

      #include "UnityCG.cginc"

      struct VertexInput {
        float4 position : POSITION;
        float2 uv : TEXCOORD0;
      };

      struct VertexOutput {
        float4 position : SV_POSITION;
	float2 uv : TEXCOORD0;
      };

      sampler2D _MainTex;
      float4 _MainTex_ST;

      sampler2D _OutraTex;
      float4 _OutraTex_ST;

      VertexOutput VertexProgram(VertexInput i) {
        VertexOutput o;
        o.position = UnityObjectToClipPos(i.position);
        o.uv = TRANSFORM_TEX(i.uv, _MainTex);
        return o;
      }

      float4 FragmentProgram(VertexOutput v) : SV_TARGET {
        float4 texColor = tex2D(_MainTex, v.uv);
        return texColor;
      }

      ENDCG
    }
  }
}

```
Note que se desejarmos utilizar também os valores de tiling e offset da segunda textura precisamos armazenar dois valores para a UV. Para isso podemos simplesmente adicionar em nosso `VertexOutput`
```c
struct VertexOutput {
  float4 position : SV_POSITION;
  float2 uv : TEXCOORD0;
  float2 uvSec : TEXCOORD1;
};
```
e no `VertexProgram`
```c
VertexOutput VertexProgram(VertexInput i) {
  VertexOutput o;
  o.position = UnityObjectToClipPos(i.position);
  o.uv = TRANSFORM_TEX(i.uv, _MainTex);
  o.uvSec = TRANSFORM_TEX(i.uv, _MainTex);
  return o;
}
```
Note que, apesar de parecer que temos *semantics* específicos para várias texturas, isso é apenas a nomenclatura adotada. Qualquer valor, além da posição, que formos adicionar ao `VertexOutput` para passar para os vértices estará em algum `TEXCOORD[n]`, mesmo que exista uma semântica específica para o `VertexProgram`, como para a normal, cores, tangente, etc.

Para combinar as texturas, podemos utilizar uma das funções oferecidas pela linguagem `HLSL`, a `lerp()`. Essa função realiza uma interpolação linear, de modo que conseguimos combinar dois valores indicando quanto queremos de cada. Vamos adicionar uma propriedade para controlar isso. Podemos modificar então nosso `FragmentProgram` para
```c
float4 FragmentProgram(VertexOutput v) : SV_TARGET {
  float4 texColor = tex2D(_MainTex, v.uv);
  float4 auxColor = tex2D(_OutraTex, v.uvSec);
  
  float4 combinedColor = lerp(texColor, auxColor, 0.5);
  
  return combinedColor;
}
```
Selecionando outra textura (também uma padrão do Unity)

![Selecionando as texturas](https://i.imgur.com/BqGTKNp.png)
![Resultado das texturas combinadas em um cubo](https://i.imgur.com/IKsMeYQ.png)

Temos então a cor combinada como 50% de cada uma das texturas. Alterando o valor no `lerp`, conseguimos qualquer combinação entre as duas, sendo 0 equivalente a 100% da primeira e 1 igual a 100% da segunda. Vamos adicionar um slider para conseguir visualizar melhor. Nas propriedades
```c
Properties{
  _MainTex("Main texture", 2D) = "white" {}
  _OutraTex("Outra textura", 2D) = "white" {}
  _Combine("Combinação das texturas", Range(0, 1)) = 0.5
}
```
Declaramos então o `float _Combine` no código e alteramos a função lerp para `lerp(texColor, auxColor, _Combine)`. Agora conseguimos ver como os valores são combinados.

![GIF animado das texturas sendo combinadas](https://i.imgur.com/3CbwMt2.gif)

### Combinando com máscaras
Outra maneira que temos de combinar texturas é usando outras texturas que atuam como máscaras. Basicamente, com uma textura em preto-e-branco, o valor da cor em cada ponto pode representar como queremos combinar as texturas. Vamos descartar o `_Combine` e adicionar uma terceira textura ao nosso shader.

Teremos então
```c
Shader "Minicurso/Texturas" {

  Properties {
    _MainTex("Main texture", 2D) = "white" {}
    _OutraTex("Outra textura", 2D) = "white" {}
    _Mask("Máscara", 2D) = "white" {}
  }

  SubShader{
    Pass {
      CGPROGRAM
      #pragma vertex VertexProgram
      #pragma fragment FragmentProgram

      #include "UnityCG.cginc"

      struct VertexInput {
        float4 position : POSITION;
        float2 uv : TEXCOORD0;
      };

      struct VertexOutput {
        float4 position : SV_POSITION;
        float2 uv : TEXCOORD0;
        float2 uvSec : TEXCOORD1;
        float2 uvMask : TEXCOORD2;
      };

      sampler2D _MainTex;
      float4 _MainTex_ST;

      sampler2D _OutraTex;
      float4 _OutraTex_ST;

      sampler2D _Mask;
      float4 _Mask_ST;

      VertexOutput VertexProgram(VertexInput i) {
        VertexOutput o;
        o.position = UnityObjectToClipPos(i.position);
        o.uv = TRANSFORM_TEX(i.uv, _MainTex);
        o.uvSec = TRANSFORM_TEX(i.uv, _OutraTex);
        o.uvMask = TRANSFORM_TEX(i.uv, _Mask);
        return o;
      }

      float4 FragmentProgram(VertexOutput v) : SV_TARGET {
        float4 texColor = tex2D(_MainTex, v.uv);
        float4 auxColor = tex2D(_OutraTex, v.uvSec);

        float combine = tex2D(_Mask, v.uvMask).x;

        float4 combinedColor = lerp(texColor, auxColor, combine);
        return combinedColor;
      }

      ENDCG
    }
  }
}
```
Utilizando algumas texturas gratuitas encontradas na internet

![Inspetor com texturas e máscara](https://i.imgur.com/WT06YDB.png)
![Resultado](https://i.imgur.com/jPTRYtN.png)

## Lugares para aprender mais
- [Documentação da Unity](https://docs.unity3d.com/Manual/ShadersOverview.html)
- [Cg Programmin/Unity](https://en.wikibooks.org/wiki/Cg_Programming/Unity)
- [The Cg Tutorial](http://developer.download.nvidia.com/CgTutorial/cg_tutorial_chapter01.html)
- [Catlike Coding](https://catlikecoding.com/unity/tutorials/rendering/)
- [Freya Holmér](https://www.youtube.com/user/Acegikm0)
- [Roystan](https://roystan.net/articles/)
- [Brackeys](https://www.youtube.com/user/Brackeys)
- [Makin' Stuff Look Good](https://www.youtube.com/channel/UCEklP9iLcpExB8vp_fWQseg)

## (coisas adicionais do shaderlab, animando as coisas, talvez noise, etc)
