async function rebuild(env) {
  await fetch(env.DEPLOY_HOOK_URL, {
    method: "POST",
  });
}
export default {
  async scheduled(event, env, ctx) {
    ctx.waitUntil(rebuild(env));
  },
};
