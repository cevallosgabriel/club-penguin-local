# 🐧 Club Penguin Community Edition (Local & Persistent)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.10](https://img.shields.io/badge/Python-3.10-blue.svg)](https://www.python.org/)
[![Status: Active](https://img.shields.io/badge/Status-Initial%20Core-blue.svg)]()
[![Platform: Cross-Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-lightgrey.svg)]()

Unificación del emulador de servidor y componentes base para **Club Penguin** (AS2/AS3), diseñado para permitir juego local, despliegues dockerizados persistentes y preservación histórica de software.

---

## 📑 Tabla de Contenidos

- [Visión General](#-visión-general)
- [Arquitectura Inicial](#-arquitectura-inicial)
- [Puesta en Marcha (Modo Persistente Docker)](#-puesta-en-marcha-modo-persistente-docker)
- [Créditos y Reconocimientos](#-créditos-y-reconocimientos)
- [Descargo de Responsabilidad (Disclaimer)](#-descargo-de-responsabilidad-disclaimer)

---

## 🧭 Visión General

Este repositorio aloja la base fundamental de un entorno modular de Club Penguin Private Server (CPPS). La meta del proyecto es unificar la lógica del servidor de mundos y login sobre Python y proveer una infraestructura sólida de base de datos y proxy reverso para juego en solitario o red de área local.

---

## 🏛️ Arquitectura Inicial

El núcleo actual del repositorio consta de:

1. **Persistente/**: Orquestación mediante Docker Compose para levantar PostgreSQL, Redis y Nginx con persistencia de datos y volúmenes montados.
2. **Motor Houdini Base**: Servidor de autenticación (`login`) y servidor de mundo (`world`) basado en Twisted y Python 3.10.

---

## 🚀 Puesta en Marcha (Modo Persistente Docker)

Para desplegar la infraestructura base con Docker:

1. Ingresa a la carpeta del entorno persistente:
   ```bash
   cd Persistente
   ```
2. Copia la plantilla de variables de entorno:
   ```bash
   cp .env.example .env
   ```
3. Levanta los contenedores:
   ```bash
   docker-compose up -d
   ```

---

## 📜 Créditos y Reconocimientos

Este proyecto recopila y preserva software libre desarrollado por la comunidad CPPS:
- **Houdini (Solero Project):** Emulador de servidor de Club Penguin escrito en Python / Twisted ([github.com/solero/houdini](https://github.com/solero/houdini)).
- **Comunidad de Preservación:** Agradecimientos a todos los desarrolladores que han mantenido con vida los protocolos de Club Penguin a lo largo de los años.

---

## ⚖️ Descargo de Responsabilidad (Disclaimer)

Este proyecto es un software comunitario desarrollado únicamente con propósitos educativos, de investigación y preservación de software. No está afiliado, respaldado ni patrocinado por Disney Interactive, The Walt Disney Company ni los desarrolladores originales de Club Penguin. Todas las marcas registradas pertenecen a sus respectivos dueños.
