import { $ } from "bun";

const gitStatus = await $`git status --porcelain`.text();
if (gitStatus.length !== 0) {
	throw new Error("`git status` is not clean.");
}

const devVersion = (await $`repo version bump dev`.text()).trim();
const version = devVersion.replace(/\-dev.*/, "");
await $`mv *.scad Cubeflower-Orchid-${version}.scad`;
await $`rm -f *.3mf`;
const file = (await $`ls *.scad`.text()).trim();
await $`cat ${file} | sed "s#^VERSION_TEXT = .*#VERSION_TEXT = ${JSON.stringify(version)};#" | sponge ${file}`;

await $`git add .`;
await $`git commit --message "Bump to next dev version (${devVersion})."`;
