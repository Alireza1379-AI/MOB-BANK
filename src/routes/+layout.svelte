<script>
  import "../app.css";
  import Header from "$lib/components/Header.svelte";
  import Footer from "$lib/components/Footer.svelte";
  import { gsap } from 'gsap';
  import { ScrollTrigger } from 'gsap/ScrollTrigger';
  import { onMount } from 'svelte';

  // Register GSAP plugins globally here
  onMount(() => {
    gsap.registerPlugin(ScrollTrigger);
  });
</script>

<div class="min-h-screen flex flex-col bg-gray-50 text-gray-900">
  <Header />
  <main class="flex-grow container mx-auto px-4 py-8">
    <slot />
  </main>
  <Footer />
</div>
