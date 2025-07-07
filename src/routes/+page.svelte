<script>
  // Homepage specific logic can go here
  // For GSAP animations later
  import { onMount } from 'svelte';
  import { gsap } from 'gsap';
  // ScrollTrigger is now registered in +layout.svelte
  // import { ScrollTrigger } from "gsap/ScrollTrigger";
  import ServiceCard from '$lib/components/ServiceCard.svelte';

  // gsap.registerPlugin(ScrollTrigger); // Moved to +layout.svelte

  const services = [
    {
      title: "Business Cards",
      description: "High-quality, custom business cards to make a lasting impression. Various finishes and paper types available.",
      imageUrl: "https://via.placeholder.com/400x300/E0E0E0/B0B0B0?text=Business+Cards",
      link: "/services/business-cards"
    },
    {
      title: "Flyers & Brochures",
      description: "Eye-catching flyers and informative brochures for your marketing campaigns. Multiple folding options.",
      imageUrl: "https://via.placeholder.com/400x300/D0D0D0/A0A0A0?text=Flyers",
      link: "/services/flyers-brochures"
    },
    {
      title: "Banners & Posters",
      description: "Large format printing for indoor and outdoor use. Durable materials and vibrant colors.",
      imageUrl: "https://via.placeholder.com/400x300/C0C0C0/909090?text=Banners",
      link: "/services/banners-posters"
    },
    {
      title: "Stickers & Labels",
      description: "Custom stickers and labels in various shapes, sizes, and materials. Perfect for branding and packaging.",
      imageUrl: "https://via.placeholder.com/400x300/B0B0B0/808080?text=Stickers",
      link: "/services/stickers-labels"
    }
  ];

  onMount(() => {
    gsap.from('h1.page-title', { duration: 1, y: -50, opacity: 0, ease: 'bounce.out' });
    gsap.from('.intro-paragraph', { duration: 1, x: -50, opacity: 0, delay: 0.5, stagger: 0.3 });

    gsap.from('.feature-card', {
      duration: 0.8,
      opacity: 0,
      y: 50,
      stagger: 0.2,
      scrollTrigger: {
        trigger: '#features',
        start: 'top 80%',
      }
    });

    gsap.from('.service-card-item', {
      duration: 0.8,
      opacity: 0,
      y: 50,
      stagger: 0.2,
      scrollTrigger: {
        trigger: '#our-services',
        start: 'top 80%',
      }
    });
  });

  // GSAP ScrollTrigger requires registration in more complex scenarios or if used extensively.
  // For SvelteKit, it's usually fine like this for simple cases, but if issues arise:
  // import { ScrollTrigger } from "gsap/ScrollTrigger";
  // gsap.registerPlugin(ScrollTrigger);
  // This should ideally be done once, e.g. in +layout.svelte or a core JS file if used globally.
  // For now, keeping it simple.
</script>

<svelte:head>
  <title>Welcome to PrintPro Services</title>
  <meta name="description" content="Your one-stop shop for all printing needs." />
</svelte:head>

<section id="hero" class="text-center py-12">
  <h1 class="page-title text-5xl font-bold text-blue-700 mb-6">High Quality Printing Services</h1>
  <p class="intro-paragraph text-xl text-gray-700 mb-4">
    From business cards to large banners, we've got you covered.
  </p>
  <p class="intro-paragraph text-xl text-gray-700 mb-8">
    Fast, reliable, and professional printing solutions tailored to your needs.
  </p>
  <a href="/services" class="bg-green-500 hover:bg-green-600 text-white font-bold py-3 px-6 rounded-lg text-lg transition duration-300 ease-in-out transform hover:scale-105 inline-block">
    Explore Our Services
  </a>
</section>

<section id="features" class="py-16 bg-white">
  <div class="container mx-auto px-4">
    <h2 class="text-3xl font-semibold text-center mb-12">Why Choose Us?</h2>
    <div class="grid md:grid-cols-3 gap-8 text-center">
      <div class="feature-card p-6 bg-gray-50 rounded-lg shadow-lg">
        <h3 class="text-2xl font-semibold text-blue-600 mb-3">Quality First</h3>
        <p>We use top-of-the-line equipment and materials to ensure the best results.</p>
      </div>
      <div class="feature-card p-6 bg-gray-50 rounded-lg shadow-lg">
        <h3 class="text-2xl font-semibold text-blue-600 mb-3">Fast Turnaround</h3>
        <p>Get your prints quickly without compromising on quality. Rush orders available.</p>
      </div>
      <div class="feature-card p-6 bg-gray-50 rounded-lg shadow-lg">
        <h3 class="text-2xl font-semibold text-blue-600 mb-3">Affordable Prices</h3>
        <p>Competitive pricing to fit your budget, with transparent quotes.</p>
      </div>
    </div>
  </div>
</section>

<section id="our-services" class="py-16">
  <div class="container mx-auto px-4">
    <h2 class="text-3xl font-semibold text-center mb-12">Our Services</h2>
    <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
      {#each services as service}
        <div class="service-card-item">
          <ServiceCard
            title={service.title}
            description={service.description}
            imageUrl={service.imageUrl}
            link={service.link}
          />
        </div>
      {/each}
    </div>
  </div>
</section>

<style>
  /* Initial state for GSAP for feature cards - handled by GSAP's `from` tween directly */
  /* For example, if not using ScrollTrigger or wanting CSS to hide initially:
  .feature-card {
    opacity: 0;
  }
  */
  h1.page-title {
    opacity: 0; /* Initial state for GSAP */
  }
  .intro-paragraph {
    opacity: 0; /* Initial state for GSAP */
  }
</style>
