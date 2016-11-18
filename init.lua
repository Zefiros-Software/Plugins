local plugins = {}
plugins._projects = {}


--[[
function plugins.linkthis()
    local name = project().name

    for plug, _ in pairs(plugins._projects) do
        print(plug)


        --print(table.tostring(zpm.build._flat,2))
        --print(table.tostring(zpm.build._flat[plug].dependency,2))

        --print(zpm.build._flat[plug].dependency.kind, "$$$$$$$$$$$")
        --if zpm.build._flat[plug].dependency.kind == "StaticLib" then
            project(plug)
            zpm.useProject( zpm.build._flat[name].dependency )
            --links( name )
            print(name,"$$$$$$$")
        --end
    end
    project(name)
end
]]

function plugins.linkthis()
    local name = project().name

    for plug, _ in pairs(plugins._projects) do

        project( plug )
        links( name )
        
        for _, proj in pairs(zpm.packages.root.projects[name].packages) do 
            zpm.useProject( proj )
        end
    end

    project(name)
end

function plugins.uses()
    local name = project().name

    for plug, _ in pairs(plugins._projects) do
        links( plug )

        -- used plugin is loaded by zpm
        if zpm.build._flat[plug] then
            zpm.useProject( zpm.build._flat[plug].dependency )
        else   
        -- otherwise it is defined in premake5.lua    
            for _, proj in pairs(zpm.packages.root.projects[name].packages) do 
                if packages.fullName == proj.fullName then
                    zpm.useProject( proj )
                end
            end
        end

    end
end

function zpm.build.commands.plugin( name )
    group( "Plugins" )
    zpm.build.rcommands.project( name )
    kind "StaticLib"
    
    plugins._projects[project().name] = true
end

premake.override(zpm.packages, "extendDev", function(base, dev)
    return base( zpm.util.concat( dev, { "plugins" } ) )
end)

premake.override(zpm.packages, "postProcess", function(base, package)
    local package = base( package )

    package.requires = package.requires and zpm.util.concat(package.requires, package.plugins and package.plugins or {} ) or {}

    return package
end)

premake.override(zpm.build, "buildConfiguration", function(base, name, conf, dep)
    local b = base( conf )

    if dep.projects then
        for projName, proj in pairs(dep.projects) do
            if plugins._projects[projName] then
                --print("yes", "@@@@@@@@@@@@@@")

                --print(table.tostring(zpm.build._flat,1))

                --zpm.uses( plugins._linkThis )
            end
        end
    end

    return b
end)

return plugins