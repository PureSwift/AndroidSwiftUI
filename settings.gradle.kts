pluginManagement {
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "AndroidSwiftUI"

// Reusable libraries live at the repo root.
include(":composeui")     // Compose Multiplatform interpreter
include(":androidbridge") // reusable Android JNI host glue

// The demo apps consume the libraries; their sources stay under Demo/.
include(":demo-app")
project(":demo-app").projectDir = file("Demo/app")
include(":demo-desktop")
project(":demo-desktop").projectDir = file("Demo/desktop")
