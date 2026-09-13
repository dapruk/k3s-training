import { readdirSync } from 'node:fs';
import { dirname, join, relative, sep } from 'node:path';

function findDockerfiles(directory) {
  const files = [];
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    const path = join(directory, entry.name);
    if (entry.isDirectory()) files.push(...findDockerfiles(path));
    if (entry.isFile() && entry.name === 'Dockerfile') files.push(path);
  }
  return files;
}

function describe(dockerfile) {
  const parts = dockerfile.split(sep);
  const caseIndex = parts.findIndex((part) => /^0[123]-/.test(part));
  const caseName = parts[caseIndex];

  let owner;
  if (parts[0] === 'participants') owner = parts[1];
  else owner = parts[1] === 'baseline' ? 'instructor-baseline' : 'instructor-replacement';

  let image;
  if (caseName === '01-fe-only') image = 'fe-only';
  else if (caseName === '02-be-only') image = 'be-only';
  else image = parts[caseIndex + 1] === 'frontend' ? 'fullstack-fe' : 'fullstack-be';

  return {
    owner,
    case: caseName,
    image,
    context: relative('.', dirname(dockerfile)),
    dockerfile: relative('.', dockerfile),
  };
}

const dockerfiles = ['instructor', 'participants']
  .flatMap(findDockerfiles)
  .sort();
const builds = dockerfiles.map(describe);

console.log(`matrix=${JSON.stringify(builds)}`);
console.log(`count=${builds.length}`);

