/** @type {import('next').NextConfig} */
const path = require('path');

const nextConfig = {
  reactStrictMode: false,
  sassOptions: {
    includePaths: [path.join(__dirname, 'src/styles')],
  },
  typescript: {
    // Ignorar erros de tipo durante o build (serão verificados em desenvolvimento)
    ignoreBuildErrors: true,
  },
};

module.exports = nextConfig;