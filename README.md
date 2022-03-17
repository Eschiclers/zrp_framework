<div id="top"></div>
<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/Eschiclers/zrp_framework">
    <img src="https://avatars.githubusercontent.com/u/13428280" alt="Logo temporal" width="80" height="80">
  </a>

<h3 align="center">ZRP Framework</h3>

  <p align="center">
    Framework para la creación de servidores y resources en FiveM basados en Zombie Role-Play
    <br />
    <a href="https://github.com/Eschiclers/zrp_framework"><strong>Explora la documentación »</strong></a>
    <br />
    <br />
    <a href="https://github.com/Eschiclers/zrp_framework/issues">Reportar un bug</a>
    ·
    <a href="https://github.com/Eschiclers/zrp_framework/issues">Solicitar función</a>
  </p>
</div>

<div align="center">

  [![Contribuyentes][contributors-shield]][contributors-url]
  [![Forks][forks-shield]][forks-url]
  [![Stargazers][stars-shield]][stars-url]
  [![Issues][issues-shield]][issues-url]
  [![Licencia AGPL-3.0][license-shield]][license-url]

</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Tabla de contenidos</summary>
  <ol>
    <li>
      <a href="#sobre-el-proyecto">Sobre el proyecto</a>
      <ul>
        <li><a href="#dependencias--requerimientos">Dependencias / Requerimientos</a></li>
      </ul>
    </li>
    <li>
      <a href="#instalación--primeros-pasos">Instalación / Primeros pasos</a>
      <ul>
        <li><a href="#requisitos-previos">Requisitos previos</a></li>
        <li><a href="#configuración-de-dependencias">Configuración de dependencias</a></li>
        <li><a href="#configuración-del-framework">Configuración del framework</a></li>
        <li><a href="#archivo-de-configuración">Archivo de configuración</a></li>
      </ul>
    </li>
    <li><a href="#cómo-usar-el-framework">Cómo usar el framework</a></li>
    <li><a href="#contribución">Contribución</a></li>
    <li><a href="#licencia">Licencia</a></li>
    <li><a href="#contacto">Contacto</a></li>
    <li><a href="#agradecimientos">Agradecimientos</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## Sobre el proyecto

Zombie Role-Play Framework es un framework para la creación de servidores y resources en FiveM basados en un modelo de juego de rol Zombie. El proyecto está altamente inspirado en [es_extended](https://github.com/esx-framework) en una de sus versiones legacy. Tan inspirado, que literalmente hay funciones que han sido directamente copiadas del proyexto.


<p align="right">(<a href="#top">volver arriba</a>)</p>



### Dependencias / Requerimientos

* [async][async-url] - ([descargar la última versión][async-latest-download])
* [mysql-async][mysql-async-url] - ([descargar última versión][mysql-async-latest-download])

> _Algunas de las dependencias son un fork de las originales. El único propósito de los forks es darle mantenimiento y asegurar que no habrá conflictos con futuras actualizaciones de las originales. Cada dependencia mantiene su `LICENCIA` original._

<p align="right">(<a href="#top">volver arriba</a>)</p>



<!-- GETTING STARTED -->
## Instalación / Primeros pasos

Para que el framework funcione correctamente, es necesario seguir una serie de pasos para poder configurarlo. Además es necesaria la instalación de algunas [dependencias](#dependencias--requerimientos).

### Requisitos previos

Antes de siquiera comenzar con la configuración del framework, es necesario que tengas instaladas las [dependencias](#dependencias--requerimientos). Para hacerlo, descárgalas desde el enlace de la lista para cada una de ellas, y extrae los archivos del zip en la carpeta `resources`. Puedes crear una carpeta nueva llamada `[dependencias]` por ejemplo o puedes arrastrarla a alguna de las carpetas ya existentes como `[system]`.

Para terminar con la instalación de las dependencias debes revisar en el repositorio o la página de cada dependencia los paso a seguir. Nosotros mostraremos aquí los más básicos.

### Configuración de dependencias

* mysql-async:
  ```lua
  ...
  set mysql_connection_string "user=zrp_username;database=zrp_framework;password=zrp_password"
  ...
  ensure mysql-async
  ...
  ```
  También puedes seguir el asistente en la página: [asistente][mysql-async-setup-url].

  Es importante que el `set mysql_connection_string` esté antes de la llamada a `ensure mysql-async`.

> Es **MUY IMPORTANTE** que todas las dependencias sean cargadas **ANTES** que el framework. Y que el framework sea cargado **ANTES** que todos los resources que lo utilicen.
  

### Configuración del framework

1. Descargar la última versión disponible (o la deseada) de la [lista de versiones][zrp-framework-releases-url].
2. Extraer el contenido del zip en la carpeta `[zrp]` dentro de `resources`. Si la carpeta `[zrp]` no existe, puedes crearla tú mismo.
3. En el caso de que la carpeta extraída no se llame `zrp_framework`, debes ponerle tú ese nombre (para evitar problemas de compatibilidad).
4. Agrega lo siguiente al archivo `server.cfg` en la carpeta del servidor
   ```lua
   ## ZRP Framework
   ensure zrp_framework
   add_ace resource.zrp_framework command.add_principal allow
   add_ace resource.zrp_framework command.add_ace allow
   ```
   Recuerda que es importante que estas líneas se incluyan **DESPUÉS** de las líneas de las dependencias y **ANTES** de los resources que utilicen el framework.
5. Para configurar el framework, puedes hacerlo desde el archivo `config.lua` dentro de la carpeta que acabas de extraer.
6. Ejecutar el archivo `zrp_framework.sql` en la base de datos para crear las tablas necesarias.

### Archivo de configuración
```lua
Config = {}
Config.Locale = 'en'
Config.CheckVersion = true
Config.MapName = 'Palencia'
Config.GameType = 'Zombie Roleplay'

Config.MaxWeight = 24

Config.Traffic = {}
Config.Traffic.PedestrianAmount = 0
Config.Traffic.ParkedAmount = 15
```

```Config.Locale = 'es'``` contiene el idioma que usará el framework. Los idiomas disponibles están en la carpeta `locales/`. En el caso de no estar el idioma que quieres, puedes crearlo tú a partir de uno ya existente o modificar uno de los existentes.

```Config.CheckVersion = true``` indica si quieres que el framework compruebe si hay alguna nueva versión existente. Lo hará una vez al iniciar el servidor, y luego una vez cada 8 horas y mostrará en consola un mensaje solamente si hay una versión disponible. No consume recursos del servidor, pero si no quiere que compruebe nuevas versiones, puede cambiarlo por ```false```.

```Config.MapName = 'Palencia'``` el nombre del mapa del servidor. Algo meramente estético y para la lista de servidores. Puede ponerle el nombre que quiera darle a su mapa.

```Config.GameType = 'Zombie Roleplay'``` el tipo de juego que usará el servidor. En este caso no recomiendo cambiarlo, pero puede hacerlo si lo desea aunque puede crear confusión entre los jugadores.

```Config.MaxWeight = 24``` el peso máximo que puede llevar un jugador en kg. Puede ser aumentado si lleva algún objeto como mochila, o disminuido si tiene alguna enfermedad o algo así por ejemplo.

```Config.Traffic.PedestrianAmount = 0``` el porcentaje en relación al juego original de los peatones que aparecerán. Ahora está a 0 pero se planea aumentar ya que los peatones serán los zombies.

```Config.Traffic.parkedAmount = 15``` el porcentaje en relación al juego original de los vehículos que aparecerán aparcados en el mapa.

<p align="right">(<a href="#top">volver arriba</a>)</p>



<!-- USAGE EXAMPLES -->
## Cómo usar el framework

Aun se está trabajando en la creación del propio framework para traer una versión estable, por lo que aún no hay ninguna documentación disponible para crear resources haciendo uso del framework. Se está trabajando en la documentación.

Hay un resource `demo` de cómo se usa el framework y cómo se planeará usar. Puede verlo en el repositorio [Eschiclers/zrp_demo][zrp-demo-url].

<p align="right">(<a href="#top">volver arriba</a>)</p>



<!-- CONTRIBUTING -->
## Contribución

Aún se está trabajando en la documentación para contribuir en el desarrollo del framework, pero puede contribuir ya haciendo [pull requests][pull-request-url].

Lo único que se pide hasta que haya documentación para las contribuciones, es seguir las [convenciones de commits][conventional-commits-url] y que se siga la estructura que tiene el proyecto.

<p align="right">(<a href="#top">volver arriba</a>)</p>



<!-- LICENSE -->
## Licencia

Este proyecto utiliza la licencia [AGPL-3.0][license-url]. Consulte el archivo `LICENSE` para más información.

<p align="right">(<a href="#top">volver arriba</a>)</p>



<!-- CONTACT -->
## Contacto

Chicle - [@eschiclers](https://twitter.com/Eschiclers) - hola@chicle.dev

Enlace del proyecto: [https://github.com/Eschiclers/zrp_framework](https://github.com/Eschiclers/zrp_framework)

<p align="right">(<a href="#top">volver arriba</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Agradecimientos

* [@othneildrew](https://github.com/othneildrew) por [esta plantilla](https://github.com/othneildrew/Best-README-Template/blob/master/BLANK_README.md) de README
* [ESX Framework](https://github.com/esx-framework) por ser la idea en la que está basada este proyecto

<p align="right">(<a href="#top">volver arriba</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/Eschiclers/zrp_framework.svg?style=for-the-badge
[contributors-url]: https://github.com/Eschiclers/zrp_framework/graphs/contributors
[pull-request-url]: https://github.com/Eschiclers/zrp_framework/pulls
[forks-shield]: https://img.shields.io/github/forks/Eschiclers/zrp_framework.svg?style=for-the-badge
[forks-url]: https://github.com/Eschiclers/zrp_framework/network/members
[stars-shield]: https://img.shields.io/github/stars/Eschiclers/zrp_framework.svg?style=for-the-badge
[stars-url]: https://github.com/Eschiclers/zrp_framework/stargazers
[issues-shield]: https://img.shields.io/github/issues/Eschiclers/zrp_framework.svg?style=for-the-badge
[issues-url]: https://github.com/Eschiclers/zrp_framework/issues
[license-shield]: https://img.shields.io/github/license/Eschiclers/zrp_framework.svg?style=for-the-badge
[license-url]: https://github.com/Eschiclers/zrp_framework/blob/master/LICENSE
[conventional-commits-url]: https://www.conventionalcommits.org/es/v1.0.0/
<!-- DEPENDENCIAS -->
[async-url]: https://github.com/Eschiclers/async
[async-latest-download]: https://github.com/Eschiclers/async/archive/refs/tags/1.0.1.zip
[mysql-async-url]: https://github.com/Eschiclers/mysql-async
[mysql-async-latest-download]: https://github.com/Eschiclers/mysql-async/archive/refs/tags/3.3.2.zip
[mysql-async-setup-url]: https://www.chicle.dev/mysql-async/
<!-- DEMOS -->
[zrp-demo-url]: https://github.com/Eschiclers/zrp_demo
<!--  -->
[zrp-framework-releases-url]: https://github.com/Eschiclers/zrp_framework/releases